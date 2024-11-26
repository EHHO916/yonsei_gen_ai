import os
from typing import List, Dict, Any
from dataclasses import dataclass

import torch
from transformers import AutoTokenizer, AutoModel
from konlpy.tag import Mecab
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import Pinecone
from langchain_community.document_loaders import TextLoader, PyPDFLoader, DirectoryLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_huggingface import HuggingFaceEmbeddings
from langchain.schema import Document
from langchain.vectorstores import Pinecone as PineconeVectorStore
from langchain_pinecone import Pinecone as LangchainPinecone
from pinecone import Pinecone
from dotenv import load_dotenv
from openai import OpenAI

load_dotenv("../.env")

@dataclass
class RAGConfig:
    pinecone_api_key: str
    pinecone_env: str
    index_name: str
    embedding_model_name: str = "klue/roberta-base"
    chunk_size: int = 1000
    chunk_overlap: int = 200
    temperature: float = 0.7
    top_k: int = 3

class KoreanTextProcessor:
    def __init__(self):
        try:
            # Set environment variable for MeCab
            os.environ["MECABRC"] = "/usr/local/etc/mecabrc"
            
            # Use the exact path from your Homebrew installation
            dicpath = '/opt/homebrew/Cellar/mecab-ko-dic/2.1.1-20180720/lib/mecab/dic/mecab-ko-dic'
            print(f"Attempting to initialize MeCab with dicpath: {dicpath}")
            print(f"Directory exists: {os.path.exists(dicpath)}")
            print(f"MECABRC path: {os.environ.get('MECABRC')}")
            
            self.mecab = Mecab(dicpath=dicpath)
            
            # Verify initialization
            test_text = "테스트"
            result = self.mecab.morphs(test_text)
            print(f"Test tokenization successful: {result}")
            
        except Exception as e:
            raise Exception(f"""
            Failed to initialize MeCab. Please try these steps:
            
            1. First, uninstall everything:
               brew uninstall mecab-ko mecab-ko-dic
               pip uninstall mecab-python3
        
            2. Then install in this specific order:
               brew install mecab-ko
               brew install mecab-ko-dic
               pip install 'mecab-python3>=1.0.6'
               
            3. Create mecabrc file:
               sudo mkdir -p /usr/local/etc
               echo "dicdir = /opt/homebrew/Cellar/mecab-ko-dic/2.1.1-20180720/lib/mecab/dic/mecab-ko-dic" | sudo tee /usr/local/etc/mecabrc
            
            Error: {str(e)}
            """)
    
    def preprocess(self, text: str) -> str:
        # Basic cleaning
        text = text.strip()
        # Normalize whitespace
        text = " ".join(text.split())
        return text
    
    def tokenize(self, text: str) -> List[str]:
        return self.mecab.morphs(text)

class KoreanEmbeddingModel:
    def __init__(self, model_name: str):
        self.tokenizer = AutoTokenizer.from_pretrained(model_name)
        self.model = AutoModel.from_pretrained(model_name)
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.model.to(self.device)
    
    def get_embeddings(self, texts: List[str]) -> torch.Tensor:
        inputs = self.tokenizer(texts, padding=True, truncation=True, 
                              max_length=512, return_tensors="pt")
        inputs = {k: v.to(self.device) for k, v in inputs.items()}
        
        with torch.no_grad(): 
            outputs = self.model(**inputs)
            embeddings = outputs.last_hidden_state[:, 0, :]  # CLS token
            embeddings = torch.nn.functional.normalize(embeddings, p=2, dim=1)
        
        return embeddings

class KoreanRAG:
    def __init__(self, config: RAGConfig):
        self.config = config
        self.text_processor = KoreanTextProcessor()
        
        # Initialize embedding model
        self.embeddings = HuggingFaceEmbeddings(
            model_name=config.embedding_model_name,
            model_kwargs={'device': 'cuda' if torch.cuda.is_available() else 'cpu'}, # No GPU.. sad
            encode_kwargs={'normalize_embeddings': True}
        )
        
        # Initialize Pinecone with new
        self.pc = Pinecone(api_key=config.pinecone_api_key)
        
        # Create index if it doesn't exist
        if config.index_name not in self.pc.list_indexes().names():
            self.pc.create_index(
                name=config.index_name,
                dimension=768,  # KLUE-RoBERTa uses 768 dimensions
                metric="cosine",
                spec={"serverless": {"cloud": "aws", "region": "us-east-1"}}
            )
        
        # Fix: Initialize Pinecone vectorstore correctly
        self.vectorstore = LangchainPinecone.from_existing_index(
            index_name=config.index_name,
            embedding=self.embeddings,
            text_key="text"
        )
        
        # Initialize text splitter
        self.text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=config.chunk_size,
            chunk_overlap=config.chunk_overlap,
            length_function=len,
            separators=["\n\n", "\n", "。", "，", " ", ""]
        )
        
        # Add OpenAI client initialization
        self.client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
    
    def load_documents(self, directory_path: str) -> List[Document]:
        loader = DirectoryLoader(
            directory_path,
            glob="**/*.pdf",  # Modify pattern based on your file types
            loader_cls=PyPDFLoader,
            show_progress=True
        )
        documents = loader.load()
        print(f"Loaded {len(documents)} documents")
        return documents
    
    def process_and_index_documents(self, documents: List[Document]):
        # Preprocess documents
        for doc in documents:
            doc.page_content = self.text_processor.preprocess(doc.page_content)
        
        # Split documents
        splits = self.text_splitter.split_documents(documents)
        
        # Index documents
        self.vectorstore.add_documents(splits)
    
    def query(self, question: str) -> Dict[str, Any]:
        processed_question = self.text_processor.preprocess(question)
        
        # Modify retriever configuration to remove unsupported parameter
        retriever = self.vectorstore.as_retriever(
            search_type="similarity",
            search_kwargs={"k": self.config.top_k}  # Remove score_threshold
        )
        docs = retriever.get_relevant_documents(processed_question)
        
        # Format context with clear document separation
        context_parts = []
        for i, doc in enumerate(docs, 1):
            context_parts.append(f"문서 {i}:\n{doc.page_content}\n")
        context = "\n".join(context_parts)
        
        response = self._generate_response(processed_question, context)
        
        return {
            "question": question,
            "context": context,
            "answer": response,
            "source_documents": docs
        }
    
    def _generate_response(self, question: str, context: str) -> str:
        messages = [
            {"role": "system", "content": """당신은 전문적인 연구 조교입니다. 
제공된 문맥을 기반으로 상세하고 구조화된 답변을 제공해야 합니다.
답변할 때 다음 지침을 따르세요:
- 문맥에 있는 정보만 사용하여 답변하세요
- 확실하지 않은 내용은 추측하지 마세요
- 가능한 한 구체적인 예시와 인용을 포함하세요
- 답변을 논리적인 섹션으로 구성하세요
- 문맥에 관련 정보가 없다면, 그 사실을 명확히 언급하세요"""},
            
            {"role": "user", "content": f"""다음은 분석해야 할 문맥입니다:

{context}

질문: {question}

단계별로 구조화된 답변을 제공해주세요."""}
        ]
        
        response = self.client.chat.completions.create(
            model="gpt-4o",  # or "gpt-3.5-turbo" for a cheaper option
            messages=messages,
            temperature=0.3,  # Lower temperature for more focused responses
            max_tokens=2000,  # Increased for more detailed responses
            presence_penalty=0.3,  # Encourage some variety in responses
            frequency_penalty=0.3  # Discourage repetition
        )
        
        return response.choices[0].message.content

# Usage example
def main():
    # Configuration
    config = RAGConfig(
        pinecone_api_key=os.getenv("PINECONE_API_KEY"),
        pinecone_env=os.getenv("PINECONE_ENV"),
        index_name="korean-docs"
    )
    
    # Initialize RAG system
    rag = KoreanRAG(config)
    
    # Load and index documents from both PDFs
    documents = []
    
    # Assuming PDFs are in a 'docs' directory
    docs_dir = "docs"  # Create this directory and put your PDFs there
    print(f"Loading documents from: {docs_dir}")
    documents = rag.load_documents(docs_dir)
    print(f"Loaded {len(documents)} documents")
    
    # Process and index all documents
    print("Processing and indexing documents...")
    rag.process_and_index_documents(documents)
    
    # Query example
    question = "논문의 주요 내용을 설명해주세요."
    print("\nQuerying system...")
    result = rag.query(question)
    print("\nRetrieved Context Length:", len(result['context']))
    print(f"\nQuestion: {result['question']}")
    print(f"\nAnswer: {result['answer']}")
    print("\nSources:")
    for i, doc in enumerate(result['source_documents'], 1):
        print(f"\nSource {i}:")
        print(f"- {doc.page_content[:200]}...")

if __name__ == "__main__":
    # First delete the existing index
    pc = Pinecone(api_key=os.getenv("PINECONE_API_KEY"))
    pc.delete_index("korean-docs")
    
    # Then run the main function which will create a new index
    main()