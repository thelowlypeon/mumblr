module Mumblr

  class AnswerPost < Post
    key :type, String, default: 'answer'
    key :asking_name, String
    key :asking_url, String
    key :question, String
    key :answer, String
  end

end
