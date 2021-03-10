require 'telegram/bot'

token = ENV['TOKEN']

REGEX_LIST = File.read('dict.csv').split("\n").sort_by(&:length).reverse.map do |line|
  msg_chars = line.strip.chars
  result_line = '.*' + (msg_chars.zip(('.' * msg_chars.size).chars).zip(('*' * msg_chars.size).chars).join)
  [line, Regexp.new(result_line)]
end

CMD = '/check@nukhl_bot'

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message&.text
    when '/start'
      bot.api.send_message(chat_id: message.chat.id, text: "пиши '#{CMD} <сообщение>' и мы узнаем, что ты имел в виду")
    else
      # if message&.text.to_s.start_with?("#{CMD} ")
        msg = message&.text.to_s.sub("#{CMD} ", '').downcase
        result = nil
        REGEX_LIST.each do |line, regex|
          if msg.match?(regex)
            line_chars = line.chars
            msg_chars = msg.chars
            result_list = []
            line_chars.each do |lc|
              msg_chars.each_with_index do |mc, index|
                if mc == lc
                  result_list << mc
                  msg_chars = msg_chars.slice(index + 1..-1)
                  break
                end
                result_list << "█"
              end
            end
            result_list << "█" * msg_chars.size
            result = result_list.join
            break
          end
        end
        bot.api.send_message(chat_id: message.chat.id, text: result) if result != nil
      # end
    end
  rescue => e
    puts e.inspect
  end
end