require 'ftools'
class MigrateAttachments < ActiveRecord::Migration
  def self.up
    ids =[1,2,3,4,5,6,7,8,10,11,12,13,14,15,16,17,18,19,20,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,61,62,63,64,65,66,67,68, 69,71,72,73,76,77,78,79,80,81]
    Dir.glob("#{RAILS_ROOT}/db/migrate/attachments/*").each do |f| 
      base = File.basename f
      match = base.match(/\d+-(\d+)-+(\d+).*/)
      if match
        qatraq_id = match[1]
        id = match[2]
        if ids.include? id.to_i
          @test_case = TestCase.find_by_qatraq_id(qatraq_id.to_i)
          if @test_case        
            file = File.new(f)
            @file_attachment = FileAttachment.new({:uploaded_data => file})
            @file_attachment.test_case_id = @test_case.id
            @file_attachment.save
          end
        else
          puts "not found #{qatraq_id}"
          p base
        end
      end
    end
  end

  def self.down
  end
end




