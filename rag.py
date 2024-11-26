from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import FAISS
from langchain_community.document_loaders import TextLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.llms import HuggingFacePipeline
from langchain.schema import Document
from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline, GPT2LMHeadModel
from typing import List, Dict
from pdfminer.high_level import extract_pages
from pdfminer.layout import LTTextContainer

class RAGSystem:
    def __init__(self, 
            model_name: str = "skt/ko-gpt-trinity-1.2B-v0.5",  
            embedding_model: str = "jhgan/ko-sroberta-multitask"):
        # Initialize language model components
        self.tokenizer = AutoTokenizer.from_pretrained(model_name)
        self.model = GPT2LMHeadModel.from_pretrained(model_name)
        
        # Create pipeline with specific Korean settings
        self.pipe = pipeline(
            "text-generation",
            model=self.model,
            tokenizer=self.tokenizer,
            max_length=512,
            device="cpu"  
        )
        self.llm = HuggingFacePipeline(pipeline=self.pipe)
        
        # Initialize text splitting and embedding components
        self.text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=300,  # Smaller chunks for Korean
            chunk_overlap=30,
            separators=["\n\n", "\n", ".", "。", "!", "?", "！", "？", " ", ""],
            keep_separator=True,
            strip_whitespace=True
        )
        
        # Use Korean-specific embeddings
        self.embeddings = HuggingFaceEmbeddings(
            model_name=embedding_model,
            model_kwargs={'device': 'cpu'}
        )
        self.vector_store = None

    def load_documents(self, file_paths: List[str]):
        """Load and process documents from various sources"""
        documents = []
        
        for path in file_paths:
            if path.endswith('.pdf'):
                # Use pdfminer to extract text
                for page_text in extract_text_by_page(path):
                    documents.append(Document(
                        page_content=page_text,
                        metadata={"source": path}
                    ))
            elif path.endswith('.txt'):
                loader = TextLoader(path)
                documents.extend(loader.load())
            else:
                continue
                
        # Split documents into chunks
        texts = self.text_splitter.split_documents(documents)
        
        # Create vector store
        self.vector_store = FAISS.from_documents(texts, self.embeddings)
        
        return len(texts)

    def query(self, question: str, k: int = 3) -> Dict:
        """Query the RAG system"""
        if not self.vector_store:
            raise ValueError("No documents loaded. Please load documents first.")

        # Retrieve relevant documents
        relevant_docs = self.vector_store.similarity_search(question, k=k)
        
        # Prepare context from relevant documents
        context = "\n".join(f"문서 {i+1}: {doc.page_content}" for i, doc in enumerate(relevant_docs))
        
        # Create prompt with context (in Korean)
        prompt = f"""
시스템: 당신은 학술 자료를 분석하고 명확하게 설명하는 전문가입니다. 
다음 문서들을 분석하여 핵심 내용을 3-4개의 완성된 문장으로 요약해주세요.

참고 문서:
{context}

질문: {question}

답변 형식:
- 완성된 문장으로 답변해주세요
- 각 문장은 마침표로 구분해주세요
- 논리적인 순서로 설명해주세요
- 참고 문헌 인용은 생략해주세요

답변: 주어진 문서들을 분석한 결과,"""
        
        # Generate response with more specific parameters
        response = self.pipe(
            prompt,
            max_length=1024,
            min_length=150,
            num_beams=4,
            temperature=0.5,
            no_repeat_ngram_size=2,
            length_penalty=2.0,
            pad_token_id=self.tokenizer.eos_token_id,
            eos_token_id=self.tokenizer.eos_token_id,
            early_stopping=False,
            do_sample=True
        )[0]['generated_text']

        response = response.replace('답변:', '').strip()

        return {
            "question": question,
            "answer": response,
            "sources": [doc.metadata for doc in relevant_docs]
        }

def extract_text_by_page(pdf_path):
    for page_layout in extract_pages(pdf_path):
        page_text = ""
        for element in page_layout:
            if isinstance(element, LTTextContainer):
                page_text += element.get_text()
        yield page_text
    #for page_number, page_text in enumerate(extract_text_by_page(pdf_path), start=1):
        #print(f"Page {page_number}:\\n{page_text}\\n{'-'*40}\\n")


# Usage example
def main():
    # Initialize RAG system
    rag_system = RAGSystem()
    
    # Load your documents
    files = [
        "./paper1.pdf",
        "./paper2.pdf",
        #"./references.txt"
    ]
    
    num_chunks = rag_system.load_documents(files)
    print(f"Loaded and processed {num_chunks} text chunks")
    
    # Query the system
    question = "논문들에 대한 주요 발견은 무엇입니까?"
    result = rag_system.query(question)
    
    print(f"Question: {result['question']}")
    print(f"Answer: {result['answer']}")
    print("\nSources:")
    for source in result['sources']:
        print(f"- {source}")

if __name__ == "__main__":
    main()

