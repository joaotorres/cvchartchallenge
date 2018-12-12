require 'rails_helper'

feature "Main", type: :feature do
  scenario "shows BS Challenge on the main page" do
    visit('/')
    expect(page).to have_content('BS Challenge')
  end

  scenario "verify button USD" do
    visit('/')
    expect(page).to have_button('button_usd')
  end

  scenario "verify button EUR" do
    visit('/')
    expect(page).to have_button('button_eur')
  end

  scenario "verify button ARS" do
    visit('/')
    expect(page).to have_button('button_ars')
  end

end


