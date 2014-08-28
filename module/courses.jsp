<%@ page import="java.util.*,	java.io.*,
	java.text.*,				java.net.*,
	java.lang.*,
	blackboard.data.*,                 blackboard.data.user.*,
    blackboard.persist.*,              blackboard.persist.user.*,
    blackboard.persist.course.*,       blackboard.persist.gradebook.*,
    blackboard.data.course.*,          blackboard.data.gradebook.*,
    blackboard.data.BbObject.*,        blackboard.db.*,
    blackboard.base.*,                 blackboard.platform.*,
    blackboard.platform.log.*,         blackboard.platform.session.*,
    blackboard.platform.persistence.*, blackboard.platform.security.*,
    blackboard.platform.plugin.PlugInUtil,	blackboard.platform.db.*"
    errorPage="/error.jsp"	%>
<%@ taglib uri="/bbData" prefix="bbData"%>
<%@ taglib uri="/bbUI" prefix="bbUI"%>
<bbData:context>
<bbUI:docTemplateHead title='Course Rosters'></bbUI:docTemplateHead>
<bbUI:docTemplateBody>
By clicking on a course name you can access the course's Photo Roster.
These Photo Rosters are also available through the Control Panel of your
course in the Course Tools section.<br /><br />
<%	UserDbLoader uLoader;  //database of users
	CourseDbLoader cLoader;  //databases of courses
	BbPersistenceManager bbPm;
	BbSessionManagerService sessionService;
	BbSession bbSession;
	AccessManagerService accessManager;
	Id sessionaccessor; //user id of current user
	Id bcourseId; //id for course
	CourseDbLoader loader; //database of courses
	Course course; //course being looked at
	String directory=PlugInUtil.getUri("nu", "studentroster", "module/studentroster.jsp");
	try
	{	//Setup for loading users
		uLoader=UserDbLoader.Default.getInstance();
		//Setup for loading courses
		cLoader=CourseDbLoader.Default.getInstance();
	  	// Get the Bb session to figure out who's running this jsp.  
	    // We can use this to check if the user is an Administrator and can run it. 
		bbPm = BbServiceManager.getPersistenceService().getDbPersistenceManager();
		sessionService = BbServiceManager.getSessionManagerService();   
	 	bbSession = sessionService.getSession( request );
	  	accessManager = (AccessManagerService) BbServiceManager.lookupService( AccessManagerService.class );
	  	sessionaccessor=bbSession.getUserId();  //id of current user
	  	BbList cList=cLoader.loadByUserIdAndCourseMembershipRole(sessionaccessor, CourseMembership.Role.INSTRUCTOR);
	  	BbList.Iterator cIterator=cList.getFilteringIterator();
	  	while(cIterator.hasNext())
		{	course=(Course)cIterator.next();
			if(!course.getServiceLevelType().equals(Course.ServiceLevel.COMMUNITY))
	  		{	out.print("<a href=\""+directory+"?course_id="+course.getId().toExternalString()+"\">"+course.getBatchUid()+":"+course.getTitle()+"</a><br />");	}
  		}
	} catch(Exception e)
	{	out.print("There was an error trying to retrieve your Courses");	}
%>
</bbUI:docTemplateBody>
</bbData:context>