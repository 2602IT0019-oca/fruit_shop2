class Product < ApplicationRecord
    validetes :name,presence: true, uniqueness: true
    validetes :price,presence: true
end
