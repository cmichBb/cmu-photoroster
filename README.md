# CMU Photo Roster for Blackboard Learn

Based on Northwood University's Photo Roster Building Block

## Version History

### v1.1.1

+ First Public Version
+ UI updated to keep the left nav bar and work better with the April 2014 Release of Learn 9.1
+ Images are not shown when attempting to print to help encourage FERPA compliance

## Installation/Configuration Notes

There are a couple of lines in `module\studentroster.jsp` that need to be customized for the Course Tool to function properly. 

`module\studentroster.jsp` Lines 111-112

	String photoBaseURL = "";	// When a user's batch_uid is appended to this String, it should be the full URL of their image
	String noPhotoURL = "";		// This is the URL to the image that should be displayed if there is no photo found for the user

