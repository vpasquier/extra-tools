# ruby studioclean.rb ~/nuxeo/thesource/thesource-ui cCIF.csv mCIF cCIF commercialCIF
require 'rubygems'
require 'nokogiri'

def walk(path, occurences, schema, newSchema, newSchemaFullName)
	sourcePath = path
	Dir.foreach(sourcePath) do |x|
		path = File.join(sourcePath, x)
		extension = File.extname(x)
		if x == "." or x == ".." or x == ".git" or extension == '.csv' or extension == '.png'
			next
		elsif File.directory?(path)
			walk(path, occurences, schema, newSchema, newSchemaFullName)
		elsif x.include? '.layout.xml' or x.include? '.tab.xml' or x.include? '.contentView.xml'
	  		@page = Nokogiri::XML(File.read(path))
	  		fields = @page.xpath('//fieldId')
	  		for entry in occurences
	  			for field in fields
	  				if field.text == entry.chomp
	  					siblings = field.parent.children
	  					for sibling in siblings
				  			if sibling.name == 'schema'
				  				sibling.content = newSchemaFullName
				  				File.write(path, @page.to_xml)
				  			end
				  			if sibling.name == 'schemaPrefix'
				  				sibling.content = newSchema
				  				File.write(path, @page.to_xml)
				  			end
			  			end
		  			end
		  		end
		  	end
		else
			lines = File.readlines(path)
			for entry in occurences
				entry = entry.chomp
				if lines.any? { |e| e.chomp.include? entry }
					data = File.read(path)
					filtered_data = data.chomp.gsub(schema+":"+entry, newSchema+":"+entry)
					File.open(path, "w") do |f|
				  		f.write(filtered_data)
				  	end
			  	end
			end
		end
	end
end

path = ARGV[0]
occurenceFile = ARGV[1]
schema = ARGV[2]
newSchema = ARGV[3]
newSchemaFullName = ARGV[4]

# Taking of occurences
occurences = File.readlines(occurenceFile)

# traverse and replace
walk(path, occurences, schema, newSchema, newSchemaFullName)