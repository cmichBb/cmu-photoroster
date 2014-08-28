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
    blackboard.platform.db.*"
    errorPage="/error.jsp"	%>
<%@ taglib uri="/bbData" prefix="bbData"%>
<%@ taglib prefix="bbNG" uri="/bbNG" %>

<%
	String iconUrl= "/images/ci/icons/bookopen_u.gif";
	String page_title= "CMU Photo Roster";
%>

<bbData:context>
<bbNG:learningSystemPage>

<bbNG:cssBlock>

<style type="text/css" media="all">
 /*

 div.ids {
 border:1px solid #000;
 height:200px;
 overflow:hidden;
 float:left;
 width:154px;
 padding:2px;
 text-align:center;
 }
 div.ids img {
  border:1px solid #000;
 }
 div.break {
  display:none;
  page-break-before:auto; 
 }
 div.button
 {	text-valign:bottom;
 	border:0;	
 	float:right;
 }
 */
/* Begin CMU Styles */
body {
	min-width: 0 !important;
}
a:hover {
	text-decoration: underline;
}
div.ids {
	border: none;
	height: 175px; /* Make room for captions */
	width: 150px;
	padding: 0;
	margin: 0;
	margin-bottom: 30px;
	margin-right: 5px;
	margin-left: 5px;
	float: left;
}
div.ids img {
	border: none;
	margin: auto;
}
div.locationPane {
	margin-top: 12px;
	margin-right: 12px;
	margin-left: 0;
	margin-bottom: 20px;
	min-width: 0 !important;
}
/* End CMU Styles */
</style>
<style type="text/css" media="print">
 div.ids {
  display:none;
 }
</style>
</bbNG:cssBlock>

<bbNG:pageHeader>
	<bbNG:pageTitleBar title="CMU Photo Roster" />
</bbNG:pageHeader>

<bbNG:breadcrumbBar>
<bbNG:breadcrumb>CMU Photo Roster</bbNG:breadcrumb>
</bbNG:breadcrumbBar>

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
	CourseMembershipDbLoader cmLoader; //users database in given course 
	CourseMembership cm; //user's membership in course
	CourseMembership.Role cmRole; //role of user in course
	String photoBaseURL = "";	// When a user's batch_uid is appended to this String, it should be the full URL of their image
	String noPhotoURL = "";		// This is the URL to the image that should be displayed if there is no photo found for the user
	//String okButton="<div class=button><table border=0><tr><td valign=\"bottom\" height=\"280px\"><a href=\"javascript:history.go(-1)\"><img alt=\"Ok\" name=\"img_ok\" border=\"0\" hspace=\"5\" src=\"/images/ci/formbtns/ok_off.gif?course_id="+
	//	request.getParameter("course_id")+"\" /></a></td></tr></table></div>";
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
	  	
	  	bcourseId=bbPm.generateId( Course.DATA_TYPE, request.getParameter("course_id")); //id for current course
	  	loader=(CourseDbLoader) bbPm.getLoader( CourseDbLoader.TYPE ); // loads current couse
		course=loader.loadById( bcourseId ); //gets course with given course id
		int printable=0;
		cmLoader=(CourseMembershipDbLoader)bbPm.getLoader(CourseMembershipDbLoader.TYPE); //loads the membership of course
		try
		{	cm=cmLoader.loadByCourseAndUserId(course.getId(),sessionaccessor);
			if(cm.getRole().equals(CourseMembership.Role.INSTRUCTOR)||cm.getRole().equals(CourseMembership.Role.TEACHING_ASSISTANT))
			{	printable=1;	}
		} catch(Exception e)
		{	printable=0;	}
		if(printable==1)
		{  	try
			{  	out.print("<br /><h4><center>The content generated from and displayed by the photo roster module is for course instructor's use only. The images displayed may not be published or distributed for any purpose.</center></h4>"); //disclaimer for no distribution
				out.print("<h2><center>"+course.getTitle()+"</center></h2>"); //gets current course description
			  	//loads user database
			  	UserDbLoader userLoader = (UserDbLoader) bbPm.getLoader(UserDbLoader.TYPE);
				BbList userList = userLoader.loadByCourseId(course.getId()); //gets current course's user list
				GenericFieldComparator comparator = new GenericFieldComparator( BaseComparator.ASCENDING, "getFamilyName", User.class );
	     		comparator.appendSecondaryComparator( new GenericFieldComparator( BaseComparator.ASCENDING, "getGivenName", User.class ) );
			    Collections.sort(userList, comparator );
				ListIterator uListIter = userList.listIterator(); //iterator to go through user list
				int i=0; //increment through array
				int j=1;
				//pulls out users one by one from user list for course
				while(uListIter.hasNext())
				{	User usertmg=(User)uListIter.next(); //user pulled form list
					//check if they have a role in course
					try
					{	//gets user's membership from current course
						cm=cmLoader.loadByCourseAndUserId(bcourseId,usertmg.getId());
						cmRole=cm.getRole(); //gets user's role from current course
					}
					catch(Exception e)
					{	cmRole=CourseMembership.Role.GUEST; //sets students role to a default of guest
					}
					//if role isn't student and more users available
			  		while(!(cmRole.equals(CourseMembership.Role.STUDENT))&&(uListIter.hasNext()))
			  		{	usertmg=(User)uListIter.next(); //gets next user
				  		try
						{	//get user's membership for current course
							cm=cmLoader.loadByCourseAndUserId(bcourseId,usertmg.getId());
							cmRole=cm.getRole(); //gets user's role in current course
						}
						catch(Exception e)
						{	cmRole=CourseMembership.Role.GUEST; //sets a default role value
						}
			  		}
			  		//if user had membership of student, add to array
			  		if(cmRole.equals(CourseMembership.Role.STUDENT))
			  		{	i++;
				  		//adds info about user and the blank jpeg for pic
				  		out.print("<div class=\"ids\">\n<img src=\""+photoBaseURL+usertmg.getBatchUid()+
				  		"\" width=\"146\" onError=\"this.src='"+noPhotoURL+"'\" border=\"1\" alt=\""
				  		+usertmg.getGivenName()+" "+usertmg.getFamilyName()+"\" /><br /><b>"+j+". "+usertmg.getGivenName()+" "+usertmg.getFamilyName()+
				  		"</b><br /><a href=\"mailto:"+usertmg.getEmailAddress()+"\">"+usertmg.getEmailAddress()+"</a></div>");
				  		j++;
				  	//	if(i%12==0)
				  	//	{	out.print("<div class=\"break\">&nbsp;</div>");	
				  	//		i=0;
				  	//	}
					}
				}
		  	}
		  	catch(KeyNotFoundException knfe)
		  	{  	out.println(knfe.getMessage()+" Key not found");  	}
		  	catch(PersistenceException pe)
		  	{  	out.println(pe.getMessage()+" blackboard problem");	}
	  	} else
	  	{	%>	<h2><center><%=course.getTitle()%></center></h2><br />You are not eligible to view this Course Roster<br />	<%
  		}
  	}
	catch(Exception e)
	{	out.println(e);	}
%>

<br clear="all" />

<form onsubmit="return validate_form(this)" method="post" action="javascript:history.go(-1);" name="Back">
<input type="submit" class="button" name="Back" value="Back" tabindex="3" />
</form>

</bbNG:learningSystemPage>
</bbData:context>
