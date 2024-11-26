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
    if is_positive:  # 긍정적 질문일 때
        if response == 1:  # 그렇다
            return 2
        elif response == 2:  # 조금 그렇다
            return 1.5
        elif response == 3:  # 보통이다
            return 1
        elif response == 4:  # 조금 아니다
            return 0.5
        elif response == 5:  # 아니다
            return 0
    else:  # 부정적 질문일 때
        if response == 1:  # 그렇다 (부정적)
            return 0
        elif response == 2:  # 조금 그렇다 (부정적)
            return 0.5  
        elif response == 3:  # 보통이다
            return 1 
        elif response == 4:  # 조금 아니다 (긍정적)
            return 1.5 
        elif response == 5:  # 아니다 (긍정적)
            return 2  


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
        file_path = file_name
        questions = load_questions(file_path)
        dimension_responses = []

        print(f"\n{dimension}에 대한 응답을 입력하세요 (1-5):")

        # 질문을 두 개씩 처리
        for i in range(0, len(questions), 2):
            # 첫 번째 질문 (긍정적)
            if i < len(questions):
                print(f"{i + 1}. {questions[i]}")
                dimension_responses.append(get_response(True))  

            # 두 번째 질문 (부정적)
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


def calculate_personality_type_and_percentages(responses):
    """선호 차원별 점수를 계산하여 성격 유형과 각 성향 비율을 결정하는 함수"""
    personality_type = ""
    percentages = {}

    for dimension, scores in responses.items():
        total_score = sum(scores)
        avg_score = total_score / len(scores)

        # 비율 계산
        if "외향(E) / 내향(I)" in dimension:
            e_percentage = (sum(1 for s in scores if s <= 1) / len(scores)) * 100
            i_percentage = 100 - e_percentage
            percentages["외향(E)"] = e_percentage
            percentages["내향(I)"] = i_percentage
            personality_type += "E" if avg_score < 1 else "I" if avg_score > 1 else "X"

        elif "감각(S) / 직관(N)" in dimension:
            s_percentage = (sum(1 for s in scores if s <= 1) / len(scores)) * 100
            n_percentage = 100 - s_percentage
            percentages["감각(S)"] = s_percentage
            percentages["직관(N)"] = n_percentage
            personality_type += "S" if avg_score < 1 else "N" if avg_score > 1 else "X"

        elif "사고(T) / 감정(F)" in dimension:
            t_percentage = (sum(1 for s in scores if s <= 1) / len(scores)) * 100
            f_percentage = 100 - t_percentage
            percentages["사고(T)"] = t_percentage
            percentages["감정(F)"] = f_percentage
            personality_type += "T" if avg_score < 1 else "F" if avg_score > 1 else "X"

        elif "판단(J) / 인식(P)" in dimension:
            j_percentage = (sum(1 for s in scores if s <= 1) / len(scores)) * 100
            p_percentage = 100 - j_percentage
            percentages["판단(J)"] = j_percentage
            percentages["인식(P)"] = p_percentage
            personality_type += "J" if avg_score < 1 else "P" if avg_score > 1 else "X"

    return personality_type, percentages


def print_results(personality_type, percentages):
    """결과를 출력하는 함수"""
    print("\nMMTIC 성격 유형 결과:")
    print(f"당신의 성격 유형은: {personality_type}입니다.")
    print("\n각 성향의 비율:")
    for trait, percentage in percentages.items():
        print(f"{trait}: {percentage:.2f}%")


def run_mmtic_test():
    """MMTIC 성격 유형 검사를 실행하는 함수"""
    print("MMTIC 성격 유형 검사를 시작합니다.")
    responses = collect_responses()
    personality_type, percentages = calculate_personality_type_and_percentages(responses)
    print_results(personality_type, percentages)


# MMTIC 검사 실행
run_mmtic_test()
