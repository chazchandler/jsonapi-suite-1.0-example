#!./ruby/bin/ruby

# require 'pp'
require 'json'
require 'active_record'
require 'kaminari'
require './z'
require './seeds'

class ApplicationResource < Z::Resource
  self.abstract_class = true
  self.adapter = Z::Adapters::ActiveRecord::Base.new
end

class EmployeeResource < ApplicationResource
  attribute :first_name, :string
  attribute :last_name, :string
  attribute :age, :integer

  has_many :positions
end

class PositionResource < ApplicationResource
  attribute :employee_id, :integer, only: [:filterable]
  attribute :department_id, :integer, only: [:filterable]
  attribute :title, :string

  belongs_to :department
end

class DepartmentResource < ApplicationResource
  attribute :name, :string
end

begin
  employees = EmployeeResource.all({
    sort: '-id',
    filter: { age: { gt: 30 } },
    page: { size: 10, number: 1 },
    include: 'positions.department'
  })

  # employees.each do |e|
  #   puts "#{e.first_name} | #{e.positions[0].title} | #{e.positions[0].department.name}"
  # end
  #
  # pp JSON.parse(employees.to_jsonapi)
  # puts "\n\n"
  # pp JSON.parse(employees.to_json)
  # puts "\n\n"
  # puts employees.to_xml

  puts JSON.generate(
    statusCode: 200,
    body:       employees.as_json
  )

rescue Exception => e
  puts JSON.generate(
    statusCode: 500,
    body:       e.message
  )

end
