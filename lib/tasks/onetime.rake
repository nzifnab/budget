namespace :onetime do
  task :go => :environment do
    puts "Updating #{Income.count} incomes"
    Income.all.each do |income|
      income.applied_at ||= income.created_at
      income.save!
    end
  end
end
