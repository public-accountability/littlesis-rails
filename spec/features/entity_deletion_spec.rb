# coding: utf-8
require 'rails_helper'

feature 'Entity deletion request & review' do
  let(:user){}
  let(:requester) { create :really_basic_user }
  let(:entity) { create :entity_person }
  let!(:deletion_request) do
    create :deletion_request, user: requester, entity: entity
  end

  before { login_as user, scope: :user }
  after { logout :user }

  describe "reviewing a deltion request" do
    before { visit review_deletion_request_path(deletion_request) }

    context "as an admin" do
      let(:user) { create(:admin_user) }

      it "shows the page" do
        successfully_visits_page review_deletion_request_path(deletion_request)
      end

      it "shows a description of the request" do
        desc = page.find("#user-request-description")
        expect(desc).to have_link requester.username, "/users/#{requester.username}"
        expect(desc).to have_text "deletion was requested"
        expect(desc).to have_text LsDate.pretty_print(deletion_request.created_at)
      end

      it "shows information about the entity to be deleted" do
        report = page.find("#deletion-report")
        expect(report).to have_text "will remove the following person"
        expect(report).to have_link entity.name, href: entity_path(entity)
        expect(report).to have_text entity.description
        expect(report).to have_text "has #{entity.link_count} relationships"
        expect(report).to have_text "Are you sure"
      end

      context "clicking `Approve`" do
        it "deletes the entity"
        it "records the approval"
      end

      context "clicking `Deny`" do
        it "does not delete the entity"
        it "records the denial"
      end
    end
  end
end
