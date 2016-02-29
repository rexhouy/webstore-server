module Admin::ProductsHelper

        def supplier_options(selected)
                suppliers = Supplier.owner(current_user.group_id).all || []
                options_from_collection_for_select(suppliers, :id, :name, selected)
        end

        def category_options(category_id)
                root = Category.root.owner(current_user.group.id)
                options = ""
                root.each do |c|
                        if c.children.empty?
                                options << "<option value='#{c.id}' #{'selected' if c.id.eql? category_id}>#{c.name}</option>"
                        else
                                options << "<optgroup label='#{c.name}'>"
                                c.children.each do |sub|
                                        options << "<option value='#{sub.id}' #{'selected' if sub.id.eql? category_id}>#{sub.name}</option>"
                                end
                                options << "</optgroup>"
                        end
                end
                options.html_safe
        end

        def channel_check_boxes
                collection_check_boxes(:product, :channel_ids, Channel.owner(current_user.id).where(id: [2, 3]), :id, :name)
        end

end
