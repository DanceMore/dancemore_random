#!/usr/bin/env ruby

# Define constants first for better organization and readability
BASE_URL = "https://uolostlands.com/imaging/outfit-creator/"
OUTPUT_DIR_ROOT = "output"
CURL_COMMANDS_FILE = "download_images.sh"

# Define object types with their valid IDs in a more organized structure
OBJECT_CATEGORIES = {
  base_model:    { ids: [12],        name: 'Base Model' },
  cloak:         { ids: [5397],     name: 'Cloak' },
  hat:           { ids: [5449, 5451, 5447, 5445, 5147, 5444, 5440,
                         5907, 5909, 5908, 5911, 5910, 5912, 5913,
                         5914, 5915, 5916], name: 'Hats' },
  pants:         { ids: [5433, 5422], name: 'Pants' },
  skirts:        { ids: [5431, 5398], name: 'Skirts' },
  shoes:         { ids: [5903, 5899, 5905, 5901], name: 'Shoes' },
  undershirt:    { ids: [7933, 5399], name: 'Undershirts' },
  shirt:         { ids: [8059, 8189, 8097, 8095, 5437, 5441], name: 'Shirts' },
  dress:         { ids: [7939, 7937, 7936], name: 'Dresses' },
  half_apron:    { ids: [5435],     name: 'Half Aprons' },
  hair:          { ids: [8252, 8251, 8253, 8260, 8261, 8263,
                         8264, 8265, 8266], name: 'Hair' },
  facial_hair:   { ids: [8254, 8255, 8256, 8257, 8268, 8267,
                         8269], name: 'Facial Hair' }
}

# Define hue range for skintone (1002..1058 with bitmask)
GENDER_HUE_RANGE = (1002..1058).map { |hue| hue | 32768 }

# Simplified gender values: female=0 female=1
GENDERS = {
  male: 0,
  female: 1
}

# we will only download the base object for now, but later we
# may want to support 1-2999 too. we will always want hue=0.
HUE_RANGE = [0]

def generate_curl_commands
  File.open(CURL_COMMANDS_FILE, 'w') do |file|
    # Process all categories, including base model with gender hues
    OBJECT_CATEGORIES.each_value do |category|
      process_category(category, file)
    end
  end

  puts "\nGenerated #{CURL_COMMANDS_FILE} with all download commands."
  puts "Execute it with: bash #{CURL_COMMANDS_FILE}"
end

def process_category(category, file)
  ids = category[:ids]
  category_name = category[:name]

  if category_name == 'Base Model'
    GENDERS.each do |gender_key, gender_data|
      hues = GENDER_HUE_RANGE
      ids.each do |id|
        hues.each do |hue|

          url = "#{BASE_URL}?id=#{id}&hue=#{hue}&female=#{gender_data}"

          # Extract non-bitmasked hue for filename
          base_hue = hue ^ 32768 if (hue & 32768) != 0
          base_hue ||= hue

          output_subdir = File.join(
            OUTPUT_DIR_ROOT,
            gender_key.to_s,
            category_name.downcase.gsub(' ', '_'),
          )

          filename = "#{base_hue}.png"
          full_path = File.join(output_subdir, filename)

          file.puts "curl '#{url}' -o '#{full_path}'"
        end
      end
    end
  else
    # Handle other categories as before
    hues = HUE_RANGE
    ids.each do |id|
      hues.each do |hue|
        GENDERS.each do |gender_key, gender_data|
          url = "#{BASE_URL}?id=#{id}&hue=#{hue}&female=#{gender_data}"

          output_subdir = File.join(
            OUTPUT_DIR_ROOT,
            gender_key.to_s,
            category_name.downcase.gsub(' ', '_'),
            id.to_s
          )

          filename = "#{hue}.png"
          full_path = File.join(output_subdir, filename)

          file.puts "curl '#{url}' -o '#{full_path}'"
        end
      end
    end
  end
end

generate_curl_commands()
