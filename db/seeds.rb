# coding: utf-8

User.create!(name: "管理者",
             email: "sample@email.com",
             employee_number: 0,
             uid: 0,
             password: "password",
             password_confirmation: "password",
             admin: true)
             
             
User.create!(name: "上長A",
             email: "superior-1@email.com",
             employee_number: 1,
             superior: true,
             uid: 1,
             password: "password",
             password_confirmation: "password",
             )
             
User.create!(name: "上長B",
             email: "superior-2@email.com",
             employee_number: 2,
             superior: true,
             uid: 2,
             password: "password",
             password_confirmation: "password",
             )

59.times do |n|
  name  = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  employee_number = n + 100
  uid = n + 100
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