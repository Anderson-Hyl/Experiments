import Foundation

@available(watchOS 7.0, *)
public extension CollectionDifference {
    /// Transforms the elements of the difference to another type using the provided transformation closure.
    ///
    /// This method iterates through each change in the `CollectionDifference`, applies the `transform` closure
    /// to each element, and constructs a new `CollectionDifference` with the transformed elements. If the
    /// transformation fails for any element (i.e., the closure returns `nil`), the entire mapping operation
    /// is aborted, and the method returns `nil`.
    ///
    /// - Returns: A `CollectionDifference<NewElement>` containing the transformed changes if all elements are successfully
    ///   transformed; otherwise, `nil` if any transformation fails.
    ///
    func mapChangeElement<NewElement>(transform: (ChangeElement) -> NewElement?) -> CollectionDifference<NewElement>? {
        var mappedChanges: [CollectionDifference<NewElement>.Change] = []
        var mappingFailed: Bool = false
        
        for change in self {
            switch change {
            case .remove(let offset, let element, let associatedWith):
                if let transformedElement = transform(element) {
                    mappedChanges.append(.remove(offset: offset, element: transformedElement, associatedWith: associatedWith))
                } else {
                    mappingFailed = true
                    break
                }
            case .insert(let offset, let element, let associatedWith):
                if let transformedElement = transform(element) {
                    mappedChanges.append(.insert(offset: offset, element: transformedElement, associatedWith: associatedWith))
                } else {
                    mappingFailed = true
                    break
                }
            }
        }
        
        if mappingFailed {
            return nil
        } else {
            return CollectionDifference<NewElement>(mappedChanges)
        }
    }
}
