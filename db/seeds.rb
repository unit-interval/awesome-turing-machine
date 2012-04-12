# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

if User.count < 10 then

  User.destroy_all
  
  Invitation.destroy_all

  roy = User.create(
    :name => 'libragold',
    :password => '3balm7kk004jdocb',
    :password_confirmation => "3balm7kk004jdocb"
  ).add_invitations()

  crystal = User.create(
    :name => 'meowanan',
    :password => 'libragold20120412',
    :password_confirmation => "libragold20120412"
  ).add_invitations()

  reserve = ['account', 'logout', 'register', 'popular', 'random', 'favorites', 'invitations']

  reserve.each do |r|
    User.create(
      :name => r,
      :password => 'hwt15nfwv01f71kp',
      :password_confirmation => "hwt15nfwv01f71kp"
    )
  end
  
end