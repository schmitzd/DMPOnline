class AdminAbility
  # All back end users (i.e. Active Admin users) are authorized using this class
  include CanCan::Ability

  def initialize(user, opts = {})
    user ||= User.new # guest user (not logged in)

    # See wikis for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
    # https://github.com/gregbell/active_admin/wiki/How-to-work-with-cancan
    
    unless user.new_record?
      if user.is_sysadmin?
        can :manage, :all
      elsif user.is_admin?
        orgs = user.is_org_admin_for

        can ["show", "index", "history"], ["dashboard", "documents", "organisations", "pages", "posts", "templates", "repositories"] 
        can ["new", "create", "show", "edit", "update", "destroy", "history"], ["documents", "pages", "posts", "templates", "repositories"]
        can ["show", "edit", "update", "publish", "unpublish", "history"], ["editions"]
        can ["edit", "update"], ["mappings"]
        can ["new", "create", "show", "edit", "update", "destroy", "rebuild", "history"], ["questions"]

        can [:read, :update], Organisation, :organisation_id => orgs
        can [:create, :read, :update, :delete, :destroy], [Template, Phase, Edition, Question, Mapping, BoilerplateText], :organisation_id => orgs
        can [:publish, :unpublish], Edition, :organisation_id => orgs
        can [:rebuild], Question, :organisation_id => orgs
        can [:create, :read, :update, :delete, :destroy], [Page, Document, Post], :organisation_id => orgs
        can [:create, :read, :update, :delete, :destroy], [Repository], :organisation_id => orgs
      end
    end

  end
end
