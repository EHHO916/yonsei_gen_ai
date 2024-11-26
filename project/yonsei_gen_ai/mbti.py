def load_questions(file_path):
    """파일에서 질문을 읽어오는 함수"""
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            questions = file.read().strip().splitlines()
        return questions
    except FileNotFoundError:
        print(f"{file_path} 파일을 찾을 수 없습니다.")
        return []

def weighted_score(response, is_positive):
    """응답에 대칭적 가중치를 적용하는 함수"""
    if is_positive:  # E/S/T/J 질문일 때
        return {1: 2, 2: 1.5, 3: 1, 4: 0.5, 5: 0}.get(response, 0)
    else:  # I/N/F/P 질문일 때
        return {1: 0, 2: 0.5, 3: 1, 4: 1.5, 5: 2}.get(response, 0)

def collect_responses():
    """사용자로부터 응답을 수집하는 함수"""
    responses = {}
    dimensions = {
        "외향(E) / 내향(I)": "외향_내향.txt",
        "감각(S) / 직관(N)": "감각_직관.txt",
        "사고(T) / 감정(F)": "사고_감정.txt",
        "판단(J) / 인식(P)": "판단_인식.txt"
    }

    for dimension, file_name in dimensions.items():
        questions = load_questions(file_name)
        dimension_responses = []

        print(f"\n{dimension}에 대한 응답을 입력하세요 (1: 그렇다, 2: 조금 그렇다, 3: 보통이다, 4: 조금 아니다, 5: 아니다)")

        for i in range(0, len(questions), 2):
            # E/S/T/J 질문
            if i < len(questions):
                print(f"{i + 1}. {questions[i]}")
                dimension_responses.append(get_response(True))

            # I/N/F/P 질문
            if i + 1 < len(questions):
                print(f"{i + 2}. {questions[i + 1]}")
                dimension_responses.append(get_response(False))

        responses[dimension] = dimension_responses
    return responses

def get_response(is_positive):
    """응답을 수집하는 별도의 함수"""
    while True:
        try:
            response = int(input("응답: "))
            if response in [1, 2, 3, 4, 5]:
                return weighted_score(response, is_positive)
            else:
                print("1에서 5 사이의 값을 입력하세요.")
        except ValueError:
            print("숫자를 입력하세요.")

def calculate_mbti_type(responses):
    """MBTI 성격 유형을 계산하는 함수"""
    mbti_type = ""

    for dimension, scores in responses.items():
        avg_score = sum(scores) / len(scores)

        if "외향(E) / 내향(I)" in dimension:
            mbti_type += "E" if avg_score > 1 else "I"
        elif "감각(S) / 직관(N)" in dimension:
            mbti_type += "S" if avg_score > 1 else "N"
        elif "사고(T) / 감정(F)" in dimension:
            mbti_type += "T" if avg_score > 1 else "F"
        elif "판단(J) / 인식(P)" in dimension:
            mbti_type += "J" if avg_score > 1 else "P"

    return mbti_type

def print_results(mbti_type):
    """결과를 출력하는 함수"""
    print("\nMBTI 성격 유형 결과:")
    print(f"당신의 MBTI 유형은: {mbti_type}입니다.")

def run_mbti_test():
    """MBTI 성격 유형 검사를 실행하는 함수"""
    print("MBTI 성격 유형 검사를 시작합니다.")
    responses = collect_responses()
    mbti_type = calculate_mbti_type(responses)
    print_results(mbti_type)

def main():
    while True:
        user_response = input("본인의 MBTI 유형을 알고 있습니까? (예/아니오): ").strip()
        if user_response == "예":
            known_mbti = input("본인의 MBTI 유형을 입력해주세요: ").strip().upper()
            print(f"당신의 MBTI 유형은 {known_mbti}입니다.")
            return
        elif user_response == "아니오":
            run_mbti_test()
            return
        else:
            print("올바른 응답을 입력해 주세요. '예' 또는 '아니오'로 답변해 주세요.")

main()
