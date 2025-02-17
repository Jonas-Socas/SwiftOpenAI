import Foundation

protocol OpenAIProtocol {
    func listModels() async throws -> ModelListDataModel?

    func completions(model: OpenAIModelType,
                     optionalParameters: CompletionsOptionalParameters?) async throws -> CompletionsDataModel?

    func createChatCompletions(model: OpenAIModelType,
                               messages: [MessageChatGPT],
                               optionalParameters: ChatCompletionsOptionalParameters?) async throws -> ChatCompletionsDataModel?

    func createChatCompletionsStream(model: OpenAIModelType,
                                     messages: [MessageChatGPT],
                                     optionalParameters: ChatCompletionsOptionalParameters?)
    async throws -> AsyncThrowingStream<ChatCompletionsStreamDataModel, Error>

    func createImages(model: OpenAIImageModelType, prompt: String, numberOfImages: Int, size: ImageSize) async throws -> CreateImageDataModel?

    func embeddings(model: OpenAIModelType, input: String) async throws -> EmbeddingResponseDataModel?

    func moderations(input: String) async throws -> ModerationDataModel?
    
    func createSpeech(model: OpenAITTSModelType, input: String, voice: OpenAIVoiceType, responseFormat: OpenAIAudioCreateSpeechResponseType, speed: Double) async throws -> Data?
    
    func createTranscription(model: OpenAITranscriptionModelType, file: Data, fileName: String, language: String, prompt: String, responseFormat: OpenAIAudioCreateTranscriptionResponseType, temperature: Double) async throws -> AsyncThrowingStream<CreateTranscriptionDataModel, Error>
}

// swiftlint:disable line_length
public class SwiftOpenAI: OpenAIProtocol {
    private let api: API
    private let apiKey: String

    private let listModelsRequest: ListModelsRequest.Init
    private let completionsRequest: CompletionsRequest.Init
    private let createChatCompletionsRequest: CreateChatCompletionsRequest.Init
    private let createChatCompletionsStreamRequest: CreateChatCompletionsStreamRequest.Init
    private let createImagesRequest: CreateImagesRequest.Init
    private let embeddingsRequest: EmbeddingsRequest.Init
    private let moderationsRequest: ModerationsRequest.Init
    private let createSpeechRequest: CreateSpeechRequest.Init
    private let createTranscriptionRequest: CreateTranscriptionRequest.Init

    public init(api: API = API(),
                apiKey: String,
                listModelsRequest: @escaping ListModelsRequest.Init = ListModelsRequest().execute,
                completionsRequest: @escaping CompletionsRequest.Init = CompletionsRequest().execute,
                createChatCompletionsRequest: @escaping CreateChatCompletionsRequest.Init = CreateChatCompletionsRequest().execute,
                createChatCompletionsStreamRequest: @escaping CreateChatCompletionsStreamRequest.Init = CreateChatCompletionsStreamRequest().execute,
                createImagesRequest: @escaping CreateImagesRequest.Init = CreateImagesRequest().execute,
                embeddingsRequest: @escaping EmbeddingsRequest.Init = EmbeddingsRequest().execute,
                moderationsRequest: @escaping ModerationsRequest.Init = ModerationsRequest().execute,
                createSpeechRequest: @escaping CreateSpeechRequest.Init = CreateSpeechRequest().execute,
                createTranscriptionRequest: @escaping CreateTranscriptionRequest.Init = CreateTranscriptionRequest().execute) {
        self.api = api
        self.apiKey = apiKey
        self.listModelsRequest = listModelsRequest
        self.completionsRequest = completionsRequest
        self.createChatCompletionsRequest = createChatCompletionsRequest
        self.createChatCompletionsStreamRequest = createChatCompletionsStreamRequest
        self.createImagesRequest = createImagesRequest
        self.embeddingsRequest = embeddingsRequest
        self.moderationsRequest = moderationsRequest
        self.createSpeechRequest = createSpeechRequest
        self.createTranscriptionRequest = createTranscriptionRequest
    }

    /**
      Retrieves a list of available OpenAI models using the OpenAI API.

      This method uses the OpenAI API to fetch a list of available models. The returned `ModelListDataModel` object contains information about each model, such as its ID, name, and capabilities.

      The method makes use of the new Swift concurrency model and supports async/await calls.

      - Throws: An error if the API call fails, or if there is a problem with parsing the received JSON data.

      - Returns: An optional `ModelListDataModel` object containing the list of available OpenAI models. Returns `nil` if there was an issue fetching the data or parsing the JSON response.

      Example usage:

          do {
              let modelList = try await listModels()
              print(modelList)
          } catch {
              print("Error: \(error)")
          }

    */
    public func listModels() async throws -> ModelListDataModel? {
        try await listModelsRequest(api, apiKey)
    }

    /**
      Generates completions for a given prompt using the OpenAI API with a specified model and optional parameters.

      This method uses the OpenAI API to generate completions for a given prompt using the specified model. You can customize the completion behavior by providing an optional `CompletionsOptionalParameters` object.

      The method makes use of the new Swift concurrency model and supports async/await calls.

      - Parameters:
        - model: An `OpenAIModelType` value representing the desired OpenAI model to use for generating completions.
        - optionalParameters: An optional `CompletionsOptionalParameters` object containing additional parameters for customizing the completion behavior, such as `maxTokens`, `temperature`, and `n`. If `nil`, the API's default settings will be used.

      - Throws: An error if the API call fails, or if there is a problem with parsing the received JSON data.

      - Returns: An optional `CompletionsDataModel` object containing the completions generated by the specified model. Returns `nil` if there was an issue fetching the data or parsing the JSON response.

      Example usage:

          let prompt = "Once upon a time, in a land far, far away,"
          let optionalParameters = CompletionsOptionalParameters(prompt: prompt, maxTokens: 50, temperature: 0.7, n: 1)
          
          do {
              let completions = try await completions(model: .gpt3_5(.gpt_3_5_turbo_1106), optionalParameters: optionalParameters)
              print(completions)
          } catch {
              print("Error: \(error)")
          }

    */
    public func completions(model: OpenAIModelType, optionalParameters: CompletionsOptionalParameters?) async throws -> CompletionsDataModel? {
        try await completionsRequest(api, apiKey, model, optionalParameters)
    }

    /**
      Generates completions for a chat-based conversation using the OpenAI API with a specified model and optional parameters, returning the entire response as a single object.

      This method uses the OpenAI API to generate completions for a chat-based conversation using the specified model. The conversation is represented by an array of `MessageChatGPT` objects. You can customize the completion behavior by providing an optional `ChatCompletionsOptionalParameters` object.

      The method makes use of the new Swift concurrency model and supports async/await calls.

      - Parameters:
        - model: An `OpenAIModelType` value representing the desired OpenAI model to use for generating chat completions.
        - messages: An array of `MessageChatGPT` objects representing the chat-based conversation.
        - optionalParameters: An optional `ChatCompletionsOptionalParameters` object containing additional parameters for customizing the chat completion behavior, such as `maxTokens`, `temperature`, and `stopPhrases`. If `nil`, the API's default settings will be used.

      - Throws: An error if the API call fails, or if there is a problem with parsing the received JSON data.

      - Returns: An optional `ChatCompletionsDataModel` object containing the chat completions generated by the specified model. Returns `nil` if there was an issue fetching the data or parsing the JSON response.

      Example usage:

          let messages: [MessageChatGPT] = [
             MessageChatGPT(text: "You are a helpful assistant.", role: .system),
             MessageChatGPT(text: "Who won the world series in 2020?", role: .user)
          ]
          let optionalParameters = ChatCompletionsOptionalParameters(temperature: 0.7, maxTokens: 50)
          
          do {
              let chatCompletions = try await createChatCompletions(model: .gpt4(.base), messages: messages, optionalParameters: optionalParameters)
              print(chatCompletions)
          } catch {
              print("Error: \(error)")
          }

    */
    public func createChatCompletions(model: OpenAIModelType,
                                      messages: [MessageChatGPT],
                                      optionalParameters: ChatCompletionsOptionalParameters? = nil) async throws -> ChatCompletionsDataModel? {
        try await createChatCompletionsRequest(api, apiKey, model, messages, optionalParameters)
    }

    /**
      Generates completions for a chat-based conversation using the OpenAI API with a specified model and optional parameters, returning an asynchronous throwing stream of responses.

      This method uses the OpenAI API to generate completions for a chat-based conversation using the specified model. The conversation is represented by an array of `MessageChatGPT` objects. You can customize the completion behavior by providing an optional `ChatCompletionsOptionalParameters` object with the `useStream` property set to `true`.

      The method makes use of the new Swift concurrency model and supports async/await calls, providing an `AsyncThrowingStream` of `ChatCompletionsStreamDataModel` objects for processing the stream of generated completions.

      - Parameters:
        - model: An `OpenAIModelType` value representing the desired OpenAI model to use for generating chat completions.
        - messages: An array of `MessageChatGPT` objects representing the chat-based conversation.
        - optionalParameters: An optional `ChatCompletionsOptionalParameters` object containing additional parameters for customizing the chat completion behavior, such as `maxTokens`, `temperature`, `useStream`, and `stopPhrases`. If `nil`, the API's default settings will be used.

      - Throws: An error if the API call fails, or if there is a problem with parsing the received JSON data.

      - Returns: An `AsyncThrowingStream<ChatCompletionsStreamDataModel, Error>` representing the asynchronous stream of chat completions generated by the specified model.

      Example usage:

            let messages: [MessageChatGPT] = [
               MessageChatGPT(text: "You are a helpful assistant.", role: .system),
               MessageChatGPT(text: "Who won the world series in 2020?", role: .user)
             ]
             let optionalParameters = ChatCompletionsOptionalParameters(temperature: 0.7, stream: true, maxTokens: 50)

             do {
                 let stream = try await createChatCompletionsStream(model: .gpt4(.base), messages: messages, optionalParameters: optionalParameters)
                 
                 for try await response in stream {
                     print(response)
                 }
             } catch {
                 print("Error: \(error)")
             }
    */
    public func createChatCompletionsStream(model: OpenAIModelType,
                                            messages: [MessageChatGPT],
                                            optionalParameters: ChatCompletionsOptionalParameters? = nil) async throws -> AsyncThrowingStream<ChatCompletionsStreamDataModel, Error> {
        try createChatCompletionsStreamRequest(api, apiKey, model, messages, optionalParameters)
    }

    /**
      Generates images based on a given prompt using the OpenAI DALL-E 2 API.

      This method uses the OpenAI DALL-E 2 API to generate images based on a given prompt. You can specify the number of images you want to generate and the size of the generated images.

      The method makes use of the new Swift concurrency model and supports async/await calls.

      - Parameters:
        - prompt: A `String` representing the prompt text to be used for generating images.
        - numberOfImages: An `Int` representing the number of images to be generated.
        - size: An `ImageSize` value representing the desired size of the generated images.

      - Throws: An error if the API call fails, or if there is a problem with parsing the received JSON data.

      - Returns: An optional `CreateImageDataModel` object containing the generated images for the given prompt. Returns `nil` if there was an issue fetching the data or parsing the JSON response.

      Example usage:

          let promptText = "A beautiful sunset over the ocean."
          let numberOfImages = 4
          let imageSize: ImageSize = .s1024
          
          do {
              let images = try await createImages(prompt: promptText, numberOfImages: numberOfImages, size: imageSize)
              print(images)
          } catch {
              print("Error: \(error)")
          }

    */
    public func createImages(model: OpenAIImageModelType, prompt: String, numberOfImages: Int, size: ImageSize) async throws -> CreateImageDataModel? {
        try await createImagesRequest(api, apiKey, model, prompt, numberOfImages, size)
    }

    /**
      Generates embeddings for a given input string using the specified OpenAI model.

      This method uses the OpenAI API to generate embeddings for a given input string using the specified model. The embeddings can be used for various natural language processing tasks, such as clustering, similarity calculations, or as input for other machine learning models.

      The method makes use of the new Swift concurrency model and supports async/await calls.

      - Parameters:
        - model: An `OpenAIModelType` value representing the desired OpenAI model to use for generating embeddings.
        - input: A `String` representing the input text for which embeddings will be generated.

      - Throws: An error if the API call fails, or if there is a problem with parsing the received JSON data.

      - Returns: An optional `EmbeddingResponseDataModel` object containing the generated embeddings for the given input. Returns `nil` if there was an issue fetching the data or parsing the JSON response.

      Example usage:

          let inputText = "Embeddings are a numerical representation of text."
          
          do {
              let embeddings = try await embeddings(model: .embedding(.text_embedding_ada_002), input: inputText)
              print(embeddings)
          } catch {
              print("Error: \(error)")
          }
    */
    public func embeddings(model: OpenAIModelType, input: String) async throws -> EmbeddingResponseDataModel? {
        try await embeddingsRequest(api, apiKey, model, input)
    }

    /**
      Moderates the content of a given input string using a moderation API.

      This method uses the moderation API to analyze and moderate the content of a given input string. The analysis includes detecting and categorizing potentially harmful, inappropriate or explicit content within the input text. The moderation results can be used for content filtering, user behavior analysis, or other moderation purposes.

      The method makes use of the new Swift concurrency model and supports async/await calls.

      - Parameters:
        - input: A `String` representing the input text to be moderated.

      - Throws: An error if the API call fails, or if there is a problem with parsing the received JSON data.

      - Returns: An optional `ModerationDataModel` object containing the moderation results for the given input. Returns `nil` if there was an issue fetching the data or parsing the JSON response.

      Example usage:

          let inputText = "Some potentially harmful or explicit content."

          do {
              let moderationResults = try await moderations(input: inputText)
              print(moderationResults)
          } catch {
              print("Error: \(error)")
          }
    */
    public func moderations(input: String) async throws -> ModerationDataModel? {
        try await moderationsRequest(api, apiKey, input)
    }

    /**
      Generates speech audio from a given input text using the OpenAI Text-to-Speech API.

      This method utilizes the OpenAI Text-to-Speech API to convert a provided input text into speech audio. You can specify the desired TTS model, voice type, response format, and speech speed. The generated audio can be saved, played, or used for various applications.

      The method leverages Swift's concurrency model and supports async/await calls.

      - Parameters:
        - model: An `OpenAITTSModelType` representing the desired TTS model to use.
        - input: A `String` containing the text to be converted into speech.
        - voice: An `OpenAIVoiceType` specifying the voice style for the generated speech.
        - responseFormat: An `OpenAIAudioResponseType` indicating the desired format of the audio response.
        - speed: A `Double` representing the speech speed, with 1.0 being normal speed.

      - Throws: An error if the API call fails or if there is an issue parsing the received audio data.

      - Returns: An optional `Data` object containing the generated speech audio in the specified format. Returns `nil` if there was a problem fetching the data or parsing the audio response.

      Example usage:

          let inputText = "The quick brown fox jumped over the lazy dog."

          do {
              let audioData = try await createSpeech(model: .tts1, input: inputText, voice: .alloy, responseFormat: .mp3, speed: 1.0)
              // Save, play, or process the audio data as needed
          } catch {
              print("Error: \(error)")
          }
    */
    public func createSpeech(model: OpenAITTSModelType, input: String, voice: OpenAIVoiceType, responseFormat: OpenAIAudioCreateSpeechResponseType, speed: Double) async throws -> Data? {
        try await createSpeechRequest(api, apiKey, model, input, voice, responseFormat, speed)
    }
    
    /**
      Transcribes audio files into text using the OpenAI Transcription API.

      This method employs the OpenAI Transcription API to convert audio files into textual transcriptions. It allows you to specify the transcription model, language, and other parameters to tailor the transcription process to your needs. The method supports various file formats and provides flexibility in terms of language and response format.

      The function is designed with Swift's concurrency features and supports async/await for seamless integration into modern Swift applications.

      - Parameters:
        - model: An `OpenAITranscriptionModelType` representing the chosen model for transcription.
        - file: A `Data` object containing the audio file to be transcribed.
        - language: A `String` specifying the language of the audio content.
        - prompt: A `String` used to provide any specific instructions or context for the transcription.
        - responseFormat: An `OpenAIAudioResponseType` indicating the format of the transcription response.
        - temperature: A `Double` that adjusts the creativity or variability of the transcription.

      - Throws: An error if the API request fails or if there are issues in processing the audio file.

      - Returns: An `AsyncThrowingStream` of `CreateTranscriptionDataModel`, providing a stream of transcription results or errors encountered during the process.

      Example usage:

          let audioFileData = // Your audio file data here

          do {
              let transcriptionStream = try await createTranscription(model: .base, file: audioFileData, language: "en", prompt: "General transcription", responseFormat: .json, temperature: 0.5)
              
              for try await transcription in transcriptionStream {
                  // Process each transcription result
              }
          } catch {
              print("Error: \(error)")
          }
    */
    public func createTranscription(model: OpenAITranscriptionModelType, file: Data, fileName: String, language: String, prompt: String, responseFormat: OpenAIAudioCreateTranscriptionResponseType, temperature: Double) async throws -> AsyncThrowingStream<CreateTranscriptionDataModel, Error> {
        try await createTranscriptionRequest(api, apiKey, file, fileName, model, language, prompt, responseFormat, temperature)
    }
}
// swiftlint:enable line_length
