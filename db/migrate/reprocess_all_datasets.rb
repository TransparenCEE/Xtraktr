# data_type field was added to questions
# update all questions to have categorical data_value where is_analysable is true

puts "Reprocess datasets - data_items by new fixed schema and related fields"
Dataset.each do |d|
  puts "updating #{d.title}"

  d.reprocess_file  
  d.check_questions_for_changes_status = true
  d.save

end