#!/usr/bin/ruby
# Encoding: utf-8

editor = ENV['EDITOR'] != 'none' ? ENV['EDITOR'] : 'vim'
message_file = ARGV[0]

def subject_forbidden_words(subject)
  forbidden = [ 'and', 'also', 'furthermore', 'changed', 'remove', 'file', 'files', 'actual', 'add', 'adding', 'updated', 'improved', 'improving', 'modified', 'modifying', 'added', 'now', 'updated', 'works', 'merged' ]
	found = forbidden.select {|word| subject.include? word }
  error_msg = 'Error: Subject should not use these words: ' + found.join(', ')  if found.length > 0
  return error_msg
end

def imperative_first_word(word)
  words = ['do', 'don\'t','allow','show', 'use', 'fix', 'merge', 'handle', 'put']

  error_msg = 'Error: First word is not imperative!' unless words.include? word

  return error_msg
end


while true
  commit_msg = []
  errors = []

  subject = (File.foreach(message_file).first).downcase
  wrong_words = subject_forbidden_words subject
  errors.push wrong_words if wrong_words
  subject.strip!

  words = subject.split(" ")
  if words.length > 1
    first_word = (words.first[0] == '[') ? words[1] : words.first
    no_imperative = imperative_first_word first_word
    errors.push no_imperative if no_imperative
  else
    errors.push "Git comment too short!"
  end

  puts errors.join(' ')

  unless errors.empty?
    
    File.open(message_file, 'r') do |line|
      if line =~ /[\s]*\#[\s]*[\w]/
        puts "huzzah" + line
      end 
      commit_msg.push line
    end

    File.open(message_file, 'a') do |file|
      file.puts "\n# GIT COMMIT MESSAGE FORMAT ERRORS:"
      errors.each { |error| file.puts "#    #{error}" }
      file.puts "\n"
      commit_msg.each { |line| file.puts line }
    end
    puts 'Invalid git commit message format.  Press y to edit and n to cancel the commit. [y/n]'
    choice = $stdin.gets.chomp
    exit 1 if %w(no n).include?(choice.downcase)
    next if system(editor,  message_file)
  end
  break
end