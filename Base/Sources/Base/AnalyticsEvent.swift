import Foundation

/// Marker for abstract analytics data.
///
/// The idea is that this data does not necessarily go directly
/// to Amplitude, but there can be additional aggregation happening
/// using AnalyticsService that will then produce the analytics events
/// to Amplitude and others.
///
/// This concept allows moving say button press counter or error counters that
/// exist solely for analytics purposes out of the main program flow.
///
/// Using a protocol instead of an enum has the benefit of breaking compile time dependencies.
/// A more rigid setup could cause massive recompilation even for tiny
/// change in analytics related code.
public protocol AnalyticsEvent {}
