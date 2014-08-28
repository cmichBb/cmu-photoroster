<%@ page import="java.util.*,	java.io.*,
     java.text.*,
     blackboard.base.*,
     blackboard.data.*,	 blackboard.persist.*,
     blackboard.data.course.*,	   blackboard.persist.course.*,
     blackboard.data.role.*,  blackboard.persist.role.*,
     blackboard.data.user.*,  blackboard.persist.user.*, 
     blackboard.data.BbObject.*,   blackboard.persist.impl.*,
     blackboard.db.*,	 blackboard.platform.*,
     blackboard.platform.db.*,	   blackboard.platform.log.*,
     blackboard.platform.persistence.*,	blackboard.platform.plugin.PlugInUtil,
     blackboard.platform.security.*,	blackboard.platform.session.*,
     blackboard.portal.data.*,	   blackboard.portal.persist.*,
     blackboard.portal.persist.impl.*,	blackboard.portal.servlet.*,
     blackboard.xml.*,	 org.w3c.dom.*"
     errorPage="/error.jsp" %>
<%@ taglib uri="/bbData" prefix="bbData"%>
<%@ taglib uri="/bbUI" prefix="bbUI"%>
<%!
public static class PhotoSearch
{    public String _url="";   public String _email="";
     public String _fname="";  public String _batchUID="";
     public String _lname="";
     public PhotoSearch(String fname, String lname, String url, String email, String batchUID)
     {    setPicURL(url); setEmail(email);
          setFirstName(fname);    setLastName(lname);
          setBatchUID(batchUID);
     }
     public void setPicURL(String url)
     {    _url=url;   }
     public void setFirstName(String fname)
     {    _fname=fname;   }
     public void setLastName(String lname)
     {    _lname=lname;   }
     public void setEmail(String email)
     {    _email=email;   }
     public void setBatchUID(String batchUID)
     {    _batchUID=batchUID; }
     public String getPicURL()
     {    return _url;    }
     public String getFirstName()
     {    return _fname;  }
     public String getLastName()
     {    return _lname;  }
     public String getEmail()
     {    return _email;  }
     public String getBatchUID()
     {    return _batchUID;   }
}
%>
<style type="text/css" media="all">
     div.ids {
	  border:1px solid #000;
	  height:190px;
	  overflow:hidden;
	  width:146px;
	  padding:0px;
     }
     div.ids img {
	  border:1px solid #000;
     }
     div.break {
	  display:none;
	  page-break-before:auto; 
     }
</style>
<style type="text/css" media="print">
     div.break {
	  height:1px;
	  display:block;
	  page-break-before:always; 
     }
</style>
<bbData:context>
     <bbUI:docTemplate>
	  <bbUI:docTemplateHead title='Photo Search'></bbUI:docTemplateHead>
	  <bbUI:docTemplateBody>
	       <bbUI:breadcrumbBar>
		    <bbUI:breadcrumb><%="Photo Search"%></bbUI:breadcrumb>
	       </bbUI:breadcrumbBar>
<%   UserDbLoader uLoader;  //database of users
     BbPersistenceManager bbPm;
     BbSessionManagerService sessionService;
     BbSession bbSession;
     AccessManagerService accessManager;
     Id sessionaccessor; //id of the person accessing jsp
     String accessorId; //accessor's user id
     String UserId="";
     String directory=PlugInUtil.getUri("nu", "studentroster", "module/studentroster.jsp");
     try
     {	  // Setup for loading users information
	  uLoader=UserDbLoader.Default.getInstance(); //accesses users database
	  // Get the Bb session to figure out who's running this jsp.  
	  // We can use this to check if the user is an Administrator and can run it. 
	  bbPm = BbServiceManager.getPersistenceService().getDbPersistenceManager();
	  sessionService = BbServiceManager.getSessionManagerService();
	  bbSession = sessionService.getSession( request );
	  accessManager = (AccessManagerService) BbServiceManager.lookupService( AccessManagerService.class );
	  sessionaccessor=bbSession.getUserId(); //gets current user's id
	  accessorId=bbSession.getUserName(); //get the current user's user id
	  Id bcourseId=null;
	  Id freMIcourseId=null;
	  Id freFLcourseId=null;
	  Id freTXcourseId=null;
	  int testing=0;
	  if(request.getServerName().equals("mytest.northwood.edu"))
	  {    bcourseId = bbPm.generateId( Course.COURSE_DATA_TYPE, "8826"); //opens course containing all users
	       testing=1;
	  }
	  else if(request.getServerName().equals("my.northwood.edu"))
	  {    bcourseId = bbPm.generateId( Course.COURSE_DATA_TYPE, "4158"); //opens course containing all users
	       freMIcourseId=bbPm.generateId( Course.COURSE_DATA_TYPE, "22609"); //opens course containing all freshman users
	       freFLcourseId=bbPm.generateId( Course.COURSE_DATA_TYPE, "4455"); //opens course containing all freshman users
	       freTXcourseId=bbPm.generateId( Course.COURSE_DATA_TYPE, "4456"); //opens course containing all freshman users
	       testing=1;
	  } else {
	       out.println("<center><strong>You do not have permission to access this information</strong></center>");
	       out.flush();
	  }
	  if(testing==1)
	  {    try
	       {    String parameterValue=""; //determines which search done
		    String parameterName=""; //holds entered information
		    String searchType="";
		    String searchValue="";
		    String fName="",lName="";
		    int mich=0,flor=0,texas=0,UC=0,devos=0,fac=0,staff=0,stu=0,fre=0,enr=0;
		    int count=0, current=0;
		    Enumeration parameters = request.getParameterNames(); //grabs information entered
		    //grabs the entered parameter
		    while(parameters.hasMoreElements())
		    {	 parameterName=(String)parameters.nextElement();
			 if(parameterName.equals("userID"))
			 {    searchType="userID";
			      break;
			 }
			 else if(parameterName.equals("studentID"))
			 {    searchType="studentID";
			      break;
			 }
			 else if(parameterName.equals("lastName"))
			 {    searchType="lastName";
			      break;
			 }
		    }
		    searchValue=request.getParameter(searchType);
		    //runs through if only if their was entered info
		    if(searchType.length()>1)
		    {	 //creates 2 user databases to look through, dependin on type of search
			 UserDbLoader userLoader = (UserDbLoader) bbPm.getLoader(UserDbLoader.TYPE);
			 User user; //holds user info
			 //if a search by username
			 if(searchType.equals("userID")||searchType.equals("studentID"))
			 {    %><center><h3>Results for: <%=searchValue%></h3></center><p><%
			      //tries to find the given user
			      try
			      {	   if(searchType.equals("userID"))
				   {	user=userLoader.loadByUserName(searchValue); //searches through database for user
				   } else
				   {	user=userLoader.loadByBatchUid(searchValue); //searches through database for user
				   }
				   //adds info about user and the blank jpeg for pic
				   out.print("<div class=\"ids\">\n<img src=\"https://www.northwood.edu/img/northwoodids/photo.aspx?id="+user.getBatchUid()+
					"\" width=\"146\" onError=\"this.src='https://www.northwood.edu/img/northwoodids/noPhoto.jpg'\" border=\"1\" alt=\""
					+user.getGivenName()+" "+user.getFamilyName()+"\" /><br /><b>"+user.getGivenName()+" "+user.getFamilyName()+
					"</b><br />"+user.getBatchUid()+"<br /><a href=\"mailto:"+user.getEmailAddress()+"\">"+user.getUserName()+
					"</a></div>");
			      }
			      catch(Exception e)
			      {}
			 } else
			 {    lName=request.getParameter("lastName");
                              lName=lName.replaceAll("~","%");
                              fName=request.getParameter("firstName");
                              fName=fName.replaceAll("~","%");
                              Connection con = null;
                              ConnectionManager connMgr = null;
                              connMgr = BbServiceManager.getJdbcService().getDefaultDatabase().getConnectionManager();
                              con = connMgr.getConnection();
                              Statement myStatement=con.createStatement();
                              String myQuery = "";//query for database
                              myQuery="select a.user_id USERNAME,a.email EMAIL,a.batch_uid BATCH_UID,a.firstname FNAME,a.lastname LNAME "+
                                   "from users a, course_users b, course_main c, user_roles d, institution_roles e " +
                                   "where d.users_pk1=a.pk1 " +
                                   "and b.users_pk1=a.pk1 " +
                                   "and b.crs_main_pk1=c.pk1 " +
                                   "and d.institution_pk1=e.pk1 " +
                                   "and a.lastname like "+lname+"' " +
                                   "and a.firstname like "+fname+"' " +
                                    "";
                              String freshCourse="and (";
                              BbList userList = new BbList(User.class);
			      PortalRoleDbLoader prLoader1=PortalRoleDbLoader.Default.getInstance();
			      String proles="and (";
                              if(request.getParameter("MI")!=null)
                              {    if(request.getParameter("fac")!=null)
                                   {    proles=proles+"m.role_id=MI_FACULTY or   ";  }
                                   if(request.getParameter("staff")!=null)
                                   {    proles=proles+"m.role_id=MI_STAFF or   ";    }
                                   freshCourse="g.crs_main_pk1=22609 or  ";
                              }
			      if(request.getParameter("FL")!=null)
                              {    if(request.getParameter("fac")!=null)
                                   {    proles=proles+"m.role_id=FL_FACULTY or   ";  }
                                   if(request.getParameter("staff")!=null)
                                   {    proles=proles+"m.role_id=FL_STAFF or   ";    }
                                   freshCourse=freshCourse+"g.crs_main_pk1=4455  or ";
                              }
			      if(request.getParameter("TX")!=null)
                              {   if(request.getParameter("fac")!=null)
                                   {    proles=proles+"m.role_id=TX_FACULTY or   ";  }
                                   if(request.getParameter("staff")!=null)
                                   {    proles=proles+"m.role_id=TX_STAFF or   ";    }
                                   freshCourse=freshCourse+"g.crs_main_pk1=4455  or ";
                              }
			      if(request.getParameter("UC")!=null)
                              {    if(request.getParameter("fac")!=null)
                                   {    proles=proles+"m.role_id=UC_FACULTY or   ";  }
                                   if(request.getParameter("staff")!=null)
                                   {    proles=proles+"m.role_id=UC_STAFF or   ";    }
                              }
			      if(request.getParameter("DeVos")!=null)
                              {    if(request.getParameter("fac")!=null)
                                   {    proles=proles+"m.role_id=DEVOS_FACULTY or   ";  }
                                   if(request.getParameter("staff")!=null)
                                   {    proles=proles+"m.role_id=DEVOS_STAFF or   ";    }
                              }
                              proles=proles.substring(0,proles.length()-5)+") ";
                              if(freshCourse.length()<6)
                              {    freshCourse="";     }
                              else
                              {    freshCourse=freshCourse.substring(0,freshCourse.length()-5)+") ";     }
                              String freshmen="or a.user_id in (select f.user_id "+
                                   "from users f, course_users g "+
                                   "where g.users_pk1=f.pk1 "+
                                   "and "+freshCourse+" "+
                                   "and g.available_ind='Y' "+
                                   "and g.roles='S' "+
                                   "and g.row_status=0	)";
                              String facStaff="or a.user_id in (select k.user_id "+
                                   "from users k, user_roles l, institution_roles m "+
                                   "where l.users_pk1=k.pk1 "+
                                   "and l.institution_roles_pk1=m.pk1 "+proles+") ";
                              String active="";
                              if(request.getParameter("all")!=null)
                              {    if(request.getParameter("enr"))
                                   {    active="or a.user_id in (select h.user_id "+
                                             "from users h, course_user i, course_main j "+
                                             "where i.user_pk1=h.pk1 "+
                                             "and i.crs_main_pk1=j.pk1 "+
                                             "and i.roles='S' "+
                                             "and j.available_ind='Y' "+
                                             "and j.row_status=0 "+
                                             "and i.available_ind='Y' "+
                                             "and i.row_status=0) " +
                                             " ";
                                   }
                                   else
                                   {    active="or ("
                                        if(request.getParameter("DeVos"))
                                        {    active="e.role_id='DEVOS_STUDENT' or "; }
                                        if(request.getParameter("FL"))
                                        {    active="e.role_id='FL_STUDENT' or "; }
                                        if(request.getParameter("MI"))
                                        {    active="e.role_id='MI_STUDENT' or "; }
                                        if(request.getParameter("TX"))
                                        {    active="e.role_id='TX_STUDENT' or "; }
                                        if(request.getParameter("UC"))
                                        {    active="e.role_id='UC_STUDENT' or "; }
                                        if(active.length()<=5)
                                        {    active="";     }
                                        else
                                        {    active=active.substring(0,active.length()-3);     }
                                   }
                              }
			      
                              String fName2=fName.replaceAll("%","");
                              String lName2=lName.replaceAll("%","");
			      if(fValid>0&&lValid>0)
			      {	   %><center><h3>Results for: <%=fName2%> <%=lName2%></h3></center><p><% }
			      else if(lValid>0)
			      {	   %><center><h3>Results for: <%=lName2%></h3></center><p><%   }
			      else if(fValid>0)
			      {	   %><center><h3>Results for: <%=fName2%></h3></center><p><%   }
			      else
			      {	   %><center><h3>Results for: </h3></center><p><%    }
			      ResultSet tabResults=myStatement.executeQuery(myQuery);
                              while(tabResults.next())
                              {    String username=null;
                                   try {     username=tabResults.getString("USERNAME");  }catch(Exception e){}
                                   String email=null;
                                   try {     email="<a href=\"mailto:"+tabResults.getString("EMAIL")+"\">"+username+"</a>";  }catch(Exception e){}
                                   String batchUID=null;
                                   try {     batchUID=tabResults.getString("USERNAME");   }catch(Exception e){}
                                   String fNameS=null;
                                   try {     fNameS=tabResults.getString("FNAME");   }catch(Exception e){}
                                   String lNameS=null;
                                   try {     lNameS=tabResults.getString("LNAME");   }catch(Exception e){}
                                   String picURL=null;
                                   try {     picURL="<div class=\"ids\">\n<img src=\"https://www.northwood.edu/img/northwoodids/photo.aspx?id="+tabResults.getString("BATCH_UID")+"\" width=\"146\" onError=\"this.src='https://www.northwood.edu/img/northwoodids/noPhoto.jpg'\" border=\"1\" alt=\""+fNameS+" "+lNameS+"\" /></div>";   }catch(Exception e){}
                                   PhotoSearch ps=new PhotoSearch(fNameS,lNameS,picURL,email,batchUID);
                                   ll_Items.add(ps);
			      }
                              if(ll_Items.size()>0)
                              {    %><bbUI:list collection="<%=ll_Items%>" collectionLabel="Photos" objectId="lineItem" className="PhotoSearch" ><%
                                   GenericFieldComparator compBatchUID = new GenericFieldComparator( BaseComparator.DESCENDING, "getBatchUID", PhotoSearch.class );
                                   GenericFieldComparator compFirstName = new GenericFieldComparator( BaseComparator.DESCENDING, "getFirstName", PhotoSearch.class );
                                   GenericFieldComparator compLastName = new GenericFieldComparator( BaseComparator.DESCENDING, "getLastName", PhotoSearch.class );
                                   GenericFieldComparator compEmail = new GenericFieldComparator( BaseComparator.DESCENDING, "getEmail", PhotoSearch.class );
                                   GenericFieldComparator compPhoto = new GenericFieldComparator( BaseComparator.DESCENDING, "getPicURL", PhotoSearch.class );
                                   %>   <bbUI:listElement comparator="<%=compLastName%>" label='Last Name' name="lName"><%=lineItem.getLastName()%></bbUI:listElement>
                                        <bbUI:listElement comparator="<%=compFirstName%>" label='First Name' name="lName"><%=lineItem.getFirstName()%></bbUI:listElement>
                                        <bbUI:listElement comparator="<%=compBatchUID%>" label='ID #' name="lName"><%=lineItem.getBatchUID()%></bbUI:listElement>
                                        <bbUI:listElement comparator="<%=compEmail%>" label='Email' name="lName"><%=lineItem.getEmail()%></bbUI:listElement>
                                        <bbUI:listElement comparator="<%=compPhoto%>" label='Photo' name="lName"><%=lineItem.getPicURL()%></bbUI:listElement>
                                    </bbUI:list><%
                              }
			 }
		    }
	       }
	       catch(Exception e)
	       {    out.println(e);	}
	  }
     }
     catch(Exception e)
     {	  out.println(e);     }
%>
	  </bbUI:docTemplateBody>
     </bbUI:docTemplate>
</bbData:context>