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
     errorPage="/error.jsp"
%>
<%@ taglib uri="/bbData" prefix="bbData"%>
<%@ taglib uri="/bbUI" prefix="bbUI"%>
<style type="text/css" media="all">
     div.ids {
	  border:1px solid #000;
	  height:280px;
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
		    String mich="",flor="",texas="",UC="",devos="",fac="",staff="",stu="",fre="",enr="";
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
			 {    BbList userList = new BbList(User.class);
			      PortalRoleDbLoader prLoader1=PortalRoleDbLoader.Default.getInstance();
			      try
			      {	   if(request.getParameter("MI").equals("yes"))
				   {    boolean test=userList.addAll(uLoader.loadByPrimaryPortalRoleId(((PortalRole)prLoader1.loadByRoleId("MI")).getId()));
					mich="yes";
				   }
			      } catch(Exception e){    }
			      try
			      {	   if(request.getParameter("FL").equals("yes"))
				   {    boolean test=userList.addAll(uLoader.loadByPrimaryPortalRoleId(((PortalRole)prLoader1.loadByRoleId("FL")).getId()));
					flor="yes";
				   }
			      } catch(Exception e){    }
			      try
			      {	   if(request.getParameter("TX").equals("yes"))
				   {    boolean test=userList.addAll(uLoader.loadByPrimaryPortalRoleId(((PortalRole)prLoader1.loadByRoleId("TX")).getId()));
					texas="yes";
				   }
			      } catch(Exception e){    }
			      try
			      {	   if(request.getParameter("UC").equals("yes"))
				   {    boolean test=userList.addAll(uLoader.loadByPrimaryPortalRoleId(((PortalRole)prLoader1.loadByRoleId("UC")).getId()));
					UC="yes";
				   }
			      } catch(Exception e){    }
			      try
			      {	   if(request.getParameter("DeVos").equals("yes"))
				   {    boolean test=userList.addAll(uLoader.loadByPrimaryPortalRoleId(((PortalRole)prLoader1.loadByRoleId("DEVOS")).getId()));
					devos="yes";
				   }
			      } catch(Exception e){    }
			      try
			      {	   if(request.getParameter("fac").equals("yes"))
				   {    fac="yes";     }
			      } catch(Exception e){    }
			      try
			      {	   if(request.getParameter("staff").equals("yes"))
				   {    staff="yes";   }
			      } catch(Exception e){    }
			      try
			      {	   if(request.getParameter("stu").equals("yes"))
				   {    stu="yes";     }
			      } catch(Exception e){    }
			      try
			      {	   if(request.getParameter("fre").equals("yes"))
				   {    fre="yes";     }
			      } catch(Exception e){    }
			      try
			      {	   if(request.getParameter("all").equals("yes"))
				   {    fre="yes"; stu="yes";    }
			      } catch(Exception e){    }
			      try
			      {	   if(request.getParameter("enr").equals("yes"))
				   {    enr="yes";     }
			      } catch(Exception e){    }
			      lName=request.getParameter("lastName");
			      String lName2=lName;
			      int lValid=0; //0 is no text, 1 is wild at end of string, 2 is wild at start, 3 is exact
			      if(lName.indexOf("~")>0)
			      {	   lValid=1; }
			      else if(lName.indexOf("~")==0)
			      {	   lValid=2; }
			      else if(lName.length()>0)
			      {	   lValid=3; }
			      lName=lName.replaceAll("~","");
			      fName=request.getParameter("firstName");
			      String fName2=fName;
			      int fValid=0; //0 is no text, 1 is wild at end of string, 2 is wild at start, 3 is exact
			      if(fName.indexOf("~")>0)
			      {	   fValid=1; }
			      else if(fName.indexOf("~")==0)
			      {	   fValid=2; }
			      else if(fName.length()>0)
			      {	   fValid=3; }
			      fName=fName.replaceAll("~","");
			      count=Integer.parseInt(request.getParameter("count"));
			      current=Integer.parseInt(request.getParameter("current"));
			      if(fValid>0&&lValid>0)
			      {	   %><center><h3>Results for: <%=fName2%> <%=lName2%></h3></center><p><% }
			      else if(lValid>0)
			      {	   %><center><h3>Results for: <%=lName2%></h3></center><p><%   }
			      else if(fValid>0)
			      {	   %><center><h3>Results for: <%=fName2%></h3></center><p><%   }
			      else
			      {	   %><center><h3>Results for: </h3></center><p><%    }
			      //gets list of all users in a course containing all users
			      BbList.Iterator uListIter = userList.getFilteringIterator(); //goes throught the list of users
			      PortalRoleDbLoader prLoader=PortalRoleDbLoader.Default.getInstance();
			      int reset1=0,reset2=0;
			      if(fac.equals("yes")&&staff.equals("yes")&&stu.equals("yes"))
			      {	   reset2=1; }
			      if(mich.equals("no")&&flor.equals("no")&&texas.equals("no")&&UC.equals("no")&&devos.equals("no"))
			      {	   reset1=2; }
			      if(fac.equals("no")&&staff.equals("no")&&stu.equals("no"))
			      {	   reset2=2; }
			      int i=0;
			      int j=1;
			      BbList printList=new BbList(User.class);
			      //puts the  users into an array
			      while(uListIter.hasNext()&&(reset1!=2||reset2!=2))
			      {	   User usertmg=(User)uListIter.next();
				   CourseMembershipDbLoader cmLoader=(CourseMembershipDbLoader)bbPm.getLoader(CourseMembershipDbLoader.TYPE); //loads the membership of course
				   if(lValid==0||(lValid==1&&usertmg.getFamilyName().toLowerCase().indexOf(lName.toLowerCase())==0)||
					     (lValid==2&&usertmg.getFamilyName().toLowerCase().indexOf(lName.toLowerCase())>0)||
					     (lValid==3&&usertmg.getFamilyName().toLowerCase().equals(lName.toLowerCase())))
				   {    if(fValid==0||(fValid==1&&usertmg.getGivenName().toLowerCase().indexOf(fName.toLowerCase())==0)||
					     (fValid==2&&usertmg.getGivenName().toLowerCase().indexOf(fName.toLowerCase())>0)||
					     (fValid==3&&usertmg.getGivenName().toLowerCase().equals(fName.toLowerCase())))
					{	  int flag1=1, flag2=0;
					     flag2=reset2;
					     if(fre.equals("yes"))
					     {    if(mich.equals("yes"))
						  {    try
						       {    if(cmLoader.loadByCourseAndUserId(freMIcourseId,usertmg.getId())!=null)
							    {    CourseMembership cm=(CourseMembership)cmLoader.loadByCourseAndUserId(freMIcourseId,usertmg.getId());
								 if(cm.getRole().equals(CourseMembership.Role.STUDENT))
								 {    flag2=1;  }
								 else
								 {    flag2=3;  }
							    }
							    else
							    {    flag2=3;  }
						       } catch(Exception e)
						       {    flag2=3;  }
						  }
						  if(texas.equals("yes")&&flag2!=1)
						  {    try
						       {    if(cmLoader.loadByCourseAndUserId(freTXcourseId,usertmg.getId())!=null)
							    {    CourseMembership cm=(CourseMembership)cmLoader.loadByCourseAndUserId(freTXcourseId,usertmg.getId());
								 if(cm.getRole().equals(CourseMembership.Role.STUDENT))
								 {    flag2=1;	}
								 else
								 {    flag2=3;  }
							    }
							    else
							    {    flag2=3;  }
						       } catch(Exception e)
						       {    flag2=3;  }
						  }
						  if(flor.equals("yes")&&flag2!=1)
						  {    try
						       {    if(cmLoader.loadByCourseAndUserId(freFLcourseId,usertmg.getId())!=null)
							    {	   CourseMembership cm=(CourseMembership)cmLoader.loadByCourseAndUserId(freFLcourseId,usertmg.getId());
								 if(cm.getRole().equals(CourseMembership.Role.STUDENT))
								 {    flag2=1;  }
								 else
								 {    flag2=3;  }
							    }
							    else
							    {    flag2=3;  }
						       } catch(Exception e)
						       {    flag2=3;  }
						  }
						  if(flag2==3)
						  {    flag2=0;  }
					     }
					     BbList prList=prLoader.loadSecondaryRolesByUserId(usertmg.getId());
					     BbList.Iterator prIterator=prList.getFilteringIterator();
					     while(prIterator.hasNext()&&(flag1==0||flag2==0))
					     {    PortalRole userPortal=(PortalRole)prIterator.next();//get next portal role
						  if(stu.equals("yes")&&userPortal.getLabel().indexOf("Student")!=-1)
						  {    if(enr.equals("yes"))
						       {    CourseDbLoader cLoader=(CourseDbLoader)bbPm.getLoader(CourseDbLoader.TYPE);
							    BbList cList=cLoader.loadByUserIdAndCourseMembershipRole(usertmg.getId(),CourseMembership.Role.STUDENT);
							    BbList.Iterator cListIterator=cList.getFilteringIterator();
							    int ind=0;
							    while(ind==0&&cListIterator.hasNext())
							    {	 Course curCrs=(Course)cListIterator.next();
								 if(curCrs.getIsAvailable())
								 {    if(mich.equals("yes")&&curCrs.getTitle().indexOf(" Michigan ")>0)
								      {    flag2=1;	ind=1;	  }
								      else if(flor.equals("yes")&&curCrs.getTitle().indexOf(" Florida ")>0)
								      {    flag2=1;	ind=1;	  }
								      else if(texas.equals("yes")&&curCrs.getTitle().indexOf(" Texas ")>0)
								      {    flag2=1;	ind=1;	  }
								      else if(devos.equals("yes")&&curCrs.getTitle().indexOf(" Grad")>0)
								      {    flag2=1;	ind=1;	  }
								      else if(UC.equals("yes")&&!(curCrs.getTitle().indexOf(" Michigan ")>0&&curCrs.getTitle().indexOf(" Florida ")>0&&curCrs.getTitle().indexOf(" Texas ")>0&&curCrs.getTitle().indexOf(" Grad")>0))
								      {    flag2=1;	ind=1;	  }
								 }
							    }
						       } else {	 flag2=1;  }
						  }
						  else if(staff.equals("yes")&&userPortal.getLabel().indexOf("Staff")!=-1)
						  {    flag2=1;  }
						  else if(fac.equals("yes")&&userPortal.getLabel().indexOf("Faculty")!=-1)
						  {    flag2=1;  }
					     }
					     if(flag1==1&&flag2==1)
					     {    printList.add(usertmg);  }
					}
				   }
			      }
			      GenericFieldComparator comparator = new GenericFieldComparator( BaseComparator.ASCENDING, "getFamilyName", User.class );
			      comparator.appendSecondaryComparator( new GenericFieldComparator( BaseComparator.ASCENDING, "getGivenName", User.class ) );
			      Collections.sort(printList, comparator );
			      BbList.Iterator printIter=printList.getFilteringIterator();
			      String results="<center>";
			      if(current!=1)
			      {	   results=results+"<a href='"+PlugInUtil.getUri("nu", "studentroster", "module/search.jsp")+
					"?firstName="+fName2+"&lastName="+lName2+
					"&MI="+mich+"&FL="+flor+"&TX="+texas+"&UC="+UC+"&DeVos="+devos+
					"&fac="+fac+"&staff="+staff+"&stu="+stu+"&fre="+fre+"&enr="+enr+
					"&count=30&current=1'><strong>First</strong></a> ";
				   results=results+"<a href='"+PlugInUtil.getUri("nu", "studentroster", "module/search.jsp")+
					"?firstName="+fName2+"&lastName="+lName2+
					"&MI="+mich+"&FL="+flor+"&TX="+texas+"&UC="+UC+"&DeVos="+devos+
					"&fac="+fac+"&staff="+staff+"&stu="+stu+"&fre="+fre+"&enr="+enr+
					"&count=30&current="+(current-30)+"'><strong>Previous</strong></a> ";
			      }
			      out.flush();
			      if((current+count-1)>printList.size())
			      {	   results=results+"<strong>Records "+current+" to "+printList.size()+" of "+printList.size()+"</strong>";  }
			      else
			      {	   results=results+"<strong>Records "+current+" to "+(current+count-1)+" of "+printList.size()+"</strong>"; }
			      if(current!=(1+30*(printList.size()/30)))
			      {	   results=results+"<a href='"+PlugInUtil.getUri("nu", "studentroster", "module/search.jsp")+
					"?firstName="+fName2+"&lastName="+lName2+
					"&MI="+mich+"&FL="+flor+"&TX="+texas+"&UC="+UC+"&DeVos="+devos+
					"&fac="+fac+"&staff="+staff+"&stu="+stu+"&fre="+fre+"&enr="+enr+
					"&count=30&current="+(current+30)+"'><strong>Next</strong></a> ";
				   results=results+"<a href='"+PlugInUtil.getUri("nu", "studentroster", "module/search.jsp")+
					"?firstName="+fName2+"&lastName="+lName2+
					"&MI="+mich+"&FL="+flor+"&TX="+texas+"&UC="+UC+"&DeVos="+devos+
					"&fac="+fac+"&staff="+staff+"&stu="+stu+"&fre="+fre+"&enr="+enr+
					"&count=30&current="+(1+30*(printList.size()/30))+"'><strong>Last</strong></a> ";
			      }
			      results=results+"</center><table border='0'><tr><td>";
			      out.println(results);
			      out.flush();
			      while(printIter.hasNext()&&i<count)
			      {	   User printUser=(User)printIter.next();
				   if(j>=current)
				   {    UserId=printUser.getBatchUid();
					//adds info about user and the blank jpeg for pic
					out.print("<div class=\"ids\">\n<img src=\"https://www.northwood.edu/img/northwoodids/photo.aspx?id="+printUser.getBatchUid()+
					     "\" width=\"146\" onError=\"this.src='https://www.northwood.edu/img/northwoodids/noPhoto.jpg'\" border=\"1\" alt=\""
					     +printUser.getGivenName()+" "+printUser.getFamilyName()+"\" /><br /><b>"+j+". "+printUser.getGivenName()+" "+printUser.getFamilyName()+
					     "</b><br />"+printUser.getBatchUid()+"<br /><a href=\"mailto:"+printUser.getEmailAddress()+"\">"+printUser.getUserName()+
					     "</a></div>");
					out.flush();
					i++;
				   }
				   j++;
			      }
			      out.println("</td></tr></table><br />"+results);
			      out.flush();
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