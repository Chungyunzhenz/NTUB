import openai

# 设置 OpenAI API 密钥
openai.api_key = ''

def test_openai():
    try:
        response = openai.ChatCompletion.create(
            model="gpt-4-turbo",  # 或者 "gpt-4"
            messages=[
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": "福爾摩斯是誰"}
            ],
            max_tokens=50,
            temperature=0.7
        )
        print(response["choices"][0]["message"]["content"])
    except Exception as e:
        print(f"OpenAI API error: {e}")

# 测试调用
test_openai()
