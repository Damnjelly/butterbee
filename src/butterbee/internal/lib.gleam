/// 
/// Returns the first element of the list, or an error if the list is empty or has more than one element.
/// 
pub fn single_element(list: List(a)) -> Result(a, String) {
  case list {
    [element] -> Ok(element)
    [] -> Error("List is empty")
    _ -> Error("List has more than one element")
  }
}
