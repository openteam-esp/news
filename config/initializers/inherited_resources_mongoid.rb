module InheritedResources::BaseHelpers
  def collection
    get_collection_ivar || set_collection_ivar(end_of_association_chain.all.to_a)
  end
end
