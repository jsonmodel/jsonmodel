/*ISO8601DateFormatter.h
 *
 *Created by Peter Hosey on 2009-04-11.
 *Copyright 2009–2013 Peter Hosey. All rights reserved.
 */

#import <Foundation/Foundation.h>

///Which of ISO 8601's three date formats the formatter should produce.
typedef NS_ENUM(NSUInteger, ISO8601DateFormat) {
	///YYYY-MM-DD.
	ISO8601DateFormatCalendar,
	///YYYY-DDD, where DDD ranges from 1 to 366; for example, 2009-32 is 2009-02-01.
	ISO8601DateFormatOrdinal,
	///YYYY-Www-D, where ww ranges from 1 to 53 (the 'W' is literal) and D ranges from 1 to 7; for example, 2009-W05-07.
	ISO8601DateFormatWeek,
};

///The default separator for time values. Currently, this is ':'.
extern const unichar ISO8601DefaultTimeSeparatorCharacter;

/*!
 *	@brief	This class converts dates to and from ISO 8601 strings.
 *
 *	@details	TL;DR: You want to use ISO 8601 for any and all dates you send or receive over the internet, unless the spec for the protocol or format you're working with specifically tells you otherwise. See http://xkcd.com/1179/ .
 *
 * ISO 8601 is most recognizable as “year-month-date” strings, such as “2013-09-08T15:06:11-0800”. Of course, as you might expect of a formal standard, it's more sophisticated (some might say complicated) than that.
 *
 * For one thing, ISO 8601 actually defines *three* different date formats. The most common one, shown above, is called the calendar date format. The other two are week dates, where the month is replaced by a week of the year and the day is a day-of-the-week (1 being Monday) rather than day-of-month, and ordinal dates, where the middle segment is dispensed with entirely and the day component is day-of-year (1–366).
 *
 * The week format is the most bizarre of them, since 7 × 52 ≠ 365. The start and end of the year for purposes of week dates usually don't line up with the start and end of the calendar year. As a result, the first and/or last day of a year in the week-date “calendar” more often than not is on a different year from the first and/or last day of that year on the actual Gregorian calendar.
 *
 * In practice, almost all ISO 8601 dates you see in the wild will be in the calendar format.
 *
 * At any rate, this formatter can both parse and unparse dates in all three formats. (By “unparse”, I mean “produce a string from”—the reverse of parsing.)
 *
 * For a good and more detailed introduction to ISO 8601, see [“A summary of the international standard date and time notation” by Markus Kuhn](http://www.cl.cam.ac.uk/~mgk25/iso-time.html). The actual standard itself can be found in PDF format online with a well-crafted web search.
 */

@interface ISO8601DateFormatter: NSFormatter

@property(nonatomic, retain) NSTimeZone *defaultTimeZone;

#pragma mark Parsing
/*!
 *	@name	Parsing
 */

//As a formatter, this object converts strings to dates.

/*!
 *	@brief	Disables various leniencies in how the formatter parses strings.
 *
 *	@details	By default, the parser allows these extensions to the ISO 8601 standard:
 *
 * - Whitespace is allowed before the date.
 * - Numbers don't have to be within range for a component. For example, you can have a string that refers to the 56th day of the hundredth month.
 * - Since 0.6, allows a single whitespace character before the time-zone specification. This extension provides compatibility with NSDate output (`description`) and input (`dateWithString:`).
 * - “Superfluous” hyphens in date specifications such as “`--DDD`” (where DDD is an ordinal day-of-year number and the year is implied) are allowed. (The standard recommends writing such a date as “`-DDD`”, with only a single hyphen. This is consistent with ordinal dates having only two components: the year and the day-of-year, separated by one hyphen.)
 * - The same goes for week dates such as “`--Www-DD`”. Again, the extra hyphen really is superfluous, but is allowed as an extension.
 * - Calendar dates with no separator between month and day-of-month are allowed, at least when they total four digits. (For example, 2013-0908, which would be interpreted as 2013-09-08.)
 * - Single-digit components are allowed. (If you wish to specify a date in a single-digit year with the strict parser, pad it with zeroes.)
 * - “YYYY-W” (without a week number after the 'W') is allowed, interpreted as “YYYY-W01-01”.
 *
 * Setting this property to `YES` will disable all of those extensions.
 *
 * These extensions are intended to help you process degenerate input (received from programs and services that use broken date-formatting libraries); whenever *you* create ISO 8601 strings, you should generate strictly-conforming ones.
 *
 * This property does not affect unparsing. The formatter always creates valid ISO 8601 strings. Any invalid string (loosely, any string that would require turning this property off to re-parse) should be considered a bug; please report it.
 */
@property BOOL parsesStrictly;

/*!
 *	@brief	Parse a string into individual date components.
 *
 *	@param	string	The string to parse. Must represent a date in one of the ISO 8601 formats.
 *	@returns	An NSDateComponents object containing most of the information parsed from the string, aside from the fraction of second and time zone (which are lost).
 *	@sa	dateComponentsFromString:timeZone:
 *	@sa	dateComponentsFromString:timeZone:range:fractionOfSecond:
 */
- (NSDateComponents *) dateComponentsFromString:(NSString *)string;
/*!
 *	@brief	Parse a string into individual date components.
 *
 *	@param	string	The string to parse. Must represent a date in one of the ISO 8601 formats.
 *	@param	outTimeZone	If non-`NULL`, an NSTimeZone object or `nil` will be stored here, depending on whether the string specified a time zone.
 *	@returns	An NSDateComponents object containing most of the information parsed from the string, aside from the fraction of second (which is lost) and time zone.
 *	@sa	dateComponentsFromString:
 *	@sa	dateComponentsFromString:timeZone:range:fractionOfSecond:
 */
- (NSDateComponents *) dateComponentsFromString:(NSString *)string timeZone:(out NSTimeZone **)outTimeZone;
/*!
 *	@brief	Parse a string into individual date components.
 *
 *	@param	string	The string to parse. Must represent a date in one of the ISO 8601 formats.
 *	@param	outTimeZone	If non-`NULL`, an NSTimeZone object or `nil` will be stored here, depending on whether the string specified a time zone.
 *	@param	outRange	If non-`NULL`, an NSRange structure will be stored here, identifying the substring of `string` that specified the date.
 *	@param	outFractionOfSecond	If non-`NULL`, an NSTimeInterval value will be stored here, containing the fraction of a second, if the string specified one. If it didn't, this will be set to zero.
 *	@returns	An NSDateComponents object containing most of the information parsed from the string, aside from the fraction of second and time zone.
 *	@sa	dateComponentsFromString:
 *	@sa	dateComponentsFromString:timeZone:
 */
- (NSDateComponents *) dateComponentsFromString:(NSString *)string timeZone:(out NSTimeZone **)outTimeZone range:(out NSRange *)outRange fractionOfSecond:(NSTimeInterval *)outFractionOfSecond;

/*!
 *	@brief	Parse a string.
 *
 *	@param	string	The string to parse. Must represent a date in one of the ISO 8601 formats.
 *	@returns	An NSDate object containing most of the information parsed from the string, aside from the time zone (which is lost).
 *	@sa	dateComponentsFromString:
 *	@sa	dateFromString:timeZone:
 *	@sa	dateFromString:timeZone:range:
 */
- (NSDate *) dateFromString:(NSString *)string;
/*!
 *	@brief	Parse a string.
 *
 *	@param	string	The string to parse. Must represent a date in one of the ISO 8601 formats.
 *	@param	outTimeZone	If non-`NULL`, an NSTimeZone object or `nil` will be stored here, depending on whether the string specified a time zone.
 *	@returns	An NSDate object containing most of the information parsed from the string, aside from the time zone.
 *	@sa	dateComponentsFromString:timeZone:
 *	@sa	dateFromString:
 *	@sa	dateFromString:timeZone:range:
 */
- (NSDate *) dateFromString:(NSString *)string timeZone:(out NSTimeZone **)outTimeZone;
/*!
 *	@brief	Parse a string into a single date, identified by an NSDate object.
 *
 *	@param	string	The string to parse. Must represent a date in one of the ISO 8601 formats.
 *	@param	outTimeZone	If non-`NULL`, an NSTimeZone object or `nil` will be stored here, depending on whether the string specified a time zone.
 *	@param	outRange	If non-`NULL`, an NSRange structure will be stored here, identifying the substring of `string` that specified the date.
 *	@returns	An NSDate object containing most of the information parsed from the string, aside from the time zone.
 *	@sa	dateComponentsFromString:timeZone:range:fractionOfSecond:
 *	@sa	dateFromString:
 *	@sa	dateFromString:timeZone:
 */
- (NSDate *) dateFromString:(NSString *)string timeZone:(out NSTimeZone **)outTimeZone range:(out NSRange *)outRange;

#pragma mark Unparsing
/*!
 *	@name	Unparsing
 */

/*!
 *	@brief	Which ISO 8601 format to format dates in.
 *
 *	@details	See ISO8601DateFormat for possible values.
 */
@property ISO8601DateFormat format;
/*!
 *	@brief	Whether strings should include time of day.
 *
 *	@details	If `NO`, strings include only the date, nothing after it.
 *
 *	@sa	timeSeparator
 *	@sa	timeZoneSeparator
 */
@property BOOL includeTime;
/*!
 *	@brief	The character to use to separate components of the time of day.
 *
 *	@details	This is used in both parsing and unparsing.
 *
 * The default value is ISO8601DefaultTimeSeparatorCharacter.
 *
 * When parsesStrictly is set to `YES`, this property is ignored. Otherwise, the parser will raise an exception if this is set to zero.
 *
 *	@sa	includeTime
 *	@sa	timeZoneSeparator
 */
@property unichar timeSeparator;
/*!
 *	@brief	The character to use to separate the hour and minute in a time zone specification.
 *
 *	@details	This is used in both parsing and unparsing.
 *
 * If zero, no separator is inserted into time zone specifications.
 *
 * The default value is zero (no separator).
 *
 *	@sa	includeTime
 *	@sa	timeSeparator
 */
@property unichar timeZoneSeparator;

/*!
 *	@brief	Produce a string that represents a date in UTC.
 *
 *	@param	date	The string to parse. Must represent a date in one of the ISO 8601 formats.
 *	@returns	A string that represents the date in UTC.
 *	@sa	stringFromDate:timeZone:
 */
- (NSString *) stringFromDate:(NSDate *)date;
/*!
 *	@brief	Produce a string that represents a date.
 *
 *	@param	date	The string to parse. Must represent a date in one of the ISO 8601 formats.
 *	@param	timeZone	An NSTimeZone object identifying the time zone in which to specify the date.
 *	@returns	A string that represents the date in the requested time zone, if possible.
 *
 *	@details	Not all dates are representable in all time zones (because of historical calendar changes, such as transitions from the Julian to the Gregorian calendar).
 *	For an example, see http://stackoverflow.com/questions/18663407/date-formatter-returns-nil-for-june .
 *	This method *should* return `nil` in such cases.
 *
 *	@sa	stringFromDate:
 */
- (NSString *) stringFromDate:(NSDate *)date timeZone:(NSTimeZone *)timeZone;

@end
