class UserDrop < BaseDrop
  liquid_attributes.push(*[ :name, :email, :first_name, :last_name ])
end