class Hash
  def symbolize_keys_deep!(h = self)
    case h
    in Hash
      h.transform_keys!(&:to_sym).transform_values! { |v| symbolize_keys_deep!(v) }
    in Array
      h.map! { |v| symbolize_keys_deep!(v) }
    else
      h
    end
  end
end
