require "application_system_test_case"

class ScoresTest < ApplicationSystemTestCase
  setup do
    @score = scores(:one)
  end

  test "visiting the index" do
    visit scores_url
    assert_selector "h1", text: "Scores"
  end

  test "should create score" do
    visit scores_url
    click_on "New score"

    fill_in "Best score", with: @score.best_score
    fill_in "Clicks count", with: @score.clicks_count
    fill_in "Data", with: @score.data
    fill_in "Name", with: @score.name
    fill_in "Time spent", with: @score.time_spent
    click_on "Create Score"

    assert_text "Score was successfully created"
    click_on "Back"
  end

  test "should update Score" do
    visit score_url(@score)
    click_on "Edit this score", match: :first

    fill_in "Best score", with: @score.best_score
    fill_in "Clicks count", with: @score.clicks_count
    fill_in "Data", with: @score.data
    fill_in "Name", with: @score.name
    fill_in "Time spent", with: @score.time_spent
    click_on "Update Score"

    assert_text "Score was successfully updated"
    click_on "Back"
  end

  test "should destroy Score" do
    visit score_url(@score)
    click_on "Destroy this score", match: :first

    assert_text "Score was successfully destroyed"
  end
end
