class QaTraqImport < ActiveRecord::Migration
#  mysql> describe testcasesversions;
#  +---------------+-----------------------+------+-----+---------+----------------+
#  | Field         | Type                  | Null | Key | Default | Extra          |
#  +---------------+-----------------------+------+-----+---------+----------------+
#  | ID            | mediumint(8) unsigned | NO   | PRI | NULL    | auto_increment | 
#  | TestCaseID    | mediumint(8) unsigned | NO   | MUL | 0       |                | 
#  | Title         | varchar(255)          | YES  |     | NULL    |                | 
#  | Content       | mediumtext            | YES  |     | NULL    |                | 
#  | MajorVersion  | mediumint(8) unsigned | NO   |     | 0       |                | 
#  | MinorVersion  | mediumint(8) unsigned | NO   |     | 0       |                | 
#  | Version       | varchar(255)          | YES  |     | NULL    |                | 
#  | DocumentID    | varchar(255)          | YES  |     | NULL    |                | 
#  | AuthorID      | mediumint(8) unsigned | NO   |     | 0       |                | 
#  | LatestVersion | tinyint(1)            | NO   |     | 0       |                | 
#  | CreationDate  | datetime              | YES  |     | NULL    |                | 
#  +---------------+-----------------------+------+-----+---------+----------------+
#
#  mysql> describe products;
#  +-------------+-----------------------+------+-----+---------+----------------+
#  | Field       | Type                  | Null | Key | Default | Extra          |
#  +-------------+-----------------------+------+-----+---------+----------------+
#  | ID          | mediumint(8) unsigned | NO   | PRI | NULL    | auto_increment | 
#  | Name        | varchar(255)          | YES  | UNI | NULL    |                | 
#  | Description | mediumtext            | YES  |     | NULL    |                | 
#  +-------------+-----------------------+------+-----+---------+----------------+
#
#  mysql> describe productscomponents;
#  +-------------+-----------------------+------+-----+---------+----------------+
#  | Field       | Type                  | Null | Key | Default | Extra          |
#  +-------------+-----------------------+------+-----+---------+----------------+
#  | ID          | mediumint(8) unsigned | NO   | PRI | NULL    | auto_increment | 
#  | Name        | varchar(255)          | YES  |     | NULL    |                | 
#  | Description | mediumtext            | YES  |     | NULL    |                | 
#  | ProductID   | mediumint(8) unsigned | NO   |     | 0       |                | 
#  | OwnerID     | mediumint(8) unsigned | NO   |     | 0       |                | 
#  +-------------+-----------------------+------+-----+---------+----------------+
#
#  mysql> describe testcasesversionscomponents;
#  +-------------------+-----------------------+------+-----+---------+-------+
#  | Field             | Type                  | Null | Key | Default | Extra |
#  +-------------------+-----------------------+------+-----+---------+-------+
#  | TestCaseVersionID | mediumint(8) unsigned | NO   | PRI | 0       |       | 
#  | ComponentID       | mediumint(8) unsigned | NO   | PRI | 0       |       | 
#  +-------------------+-----------------------+------+-----+---------+-------+
  class SomeModel < ActiveRecord::Base 
    self.abstract_class = true 
    establish_connection "qatraq"  
  end 

  def self.up
    
    TestCase.destroy_all
    Category.destroy_all
    u = User.find_or_create_by_login(:login => 'acoldham', :email => 'acoldham@expedia.com', :password => 'mttpower', :password_confirmation => 'mttpower')
    
    @rs = SomeModel.connection.execute(" \
    select tvc.*, tv.*, p.Name as ProductName, pc.name as ProductComponentName, u.LoginName as UserName from \ 
    testcasesversions tv, testcasesversionscomponents tvc, productscomponents pc, products p, users u \ 
    where tvc.TestCaseVersionID = tv.ID and tvc.ComponentID = pc.ID and pc.ProductID = p.ID and u.ID = tv.AuthorID")

    while row = @rs.fetch_hash do
      puts "importing #{row['TestCaseID']}..."
      user = User.find_or_create_by_login(:login => row['UserName'].downcase, :email => "#{row['UserName'].downcase}@expedia.com", :password => 'mttpower', :password_confirmation => 'mttpower')
      user.activate unless user.activated?
      category = Category.find_or_create_by_name(:name => row['ProductName']).children.find_or_create_by_name(:name => row['ProductComponentName'])
      test_case = TestCase.find_or_create_by_qatraq_id(:qatraq_id => row['TestCaseID'], :user_id => user.id, :category_id => category.id, :title => row['Title'], :body => row['Content'].gsub(/\n/,'<br>').gsub(/\s{4}/,'&nbsp;&nbsp;&nbsp;&nbsp;') )
    end

    #return false
  end

  def self.down
    
  end
end


# products / components / test cases
