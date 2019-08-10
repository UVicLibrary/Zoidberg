require "application_system_test_case"

class DocumentsTest < ApplicationSystemTestCase
  setup do
    @document = documents(:one)
  end

  test "visiting the index" do
    visit documents_url
    assert_selector "h1", text: "Documents"
  end

  test "creating a Document" do
    visit documents_url
    click_on "New Document"

    fill_in "Download path", with: @document.download_path
    fill_in "Profile", with: @document.profile_id
    fill_in "Source path", with: @document.source_path
    fill_in "Thumbnail path", with: @document.thumbnail_path
    fill_in "Title", with: @document.title
    click_on "Create Document"

    assert_text "Document was successfully created"
    click_on "Back"
  end

  test "updating a Document" do
    visit documents_url
    click_on "Edit", match: :first

    fill_in "Download path", with: @document.download_path
    fill_in "Profile", with: @document.profile_id
    fill_in "Source path", with: @document.source_path
    fill_in "Thumbnail path", with: @document.thumbnail_path
    fill_in "Title", with: @document.title
    click_on "Update Document"

    assert_text "Document was successfully updated"
    click_on "Back"
  end

  test "destroying a Document" do
    visit documents_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Document was successfully destroyed"
  end
end
