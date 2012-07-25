oo.each do |note|
  begin
    p note.to_json
  rescue Encoding::UndefinedConversionError
    puts "=== Error ==="
    # p note
    p note['tags'][0].force_encoding('utf-8').encoding
    # p note['tags'][0].encode('utf-8', 'ascii-8bit')
  end
end

Encoding.name_list.each do |codec|
  begin
    puts '---'
    p codec
    p s.encode(codec)
  rescue
  # rescue Encoding::UndefinedConversionError
    puts "=== Error ==="
    p codec
  end
end

