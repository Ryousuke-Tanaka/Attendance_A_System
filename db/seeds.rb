# coding: utf-8

User.create!(name: "管理者",
             email: "sample@email.com",
             employee_number: 1,
             uid: 1,
             password: "password",
             password_confirmation: "password",
             admin: true)

60.times do |n|
  name  = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  employee_number = n + 2
  uid = n + 2
  password = "password"
  User.create!(name: name,
               email: email,
               employee_number: employee_number,
               uid: uid,
               password: password,
               password_confirmation: password)
               
end

Base.create!(base_id: 1,
             base_name: "本社")