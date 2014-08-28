<%@ page import="java.util.*,	java.io.*,
	java.text.*,   				blackboard.data.*,
	blackboard.data.user.*,     blackboard.persist.*,
	blackboard.persist.user.*,  blackboard.db.*,
	blackboard.base.*,          blackboard.platform.*,
	blackboard.platform.log.*,  blackboard.platform.session.*,
	blackboard.platform.persistence.*,	blackboard.platform.security.*,
	blackboard.platform.db.*,   blackboard.portal.data.*, 
	blackboard.portal.servlet.*,	blackboard.xml.*,
	org.w3c.dom.*,              blackboard.persist.*,
	blackboard.persist.impl.*,  blackboard.portal.persist.*,
	blackboard.portal.persist.impl.*,	blackboard.platform.*,
	blackboard.platform.plugin.PlugInUtil"
	errorPage="/error.jsp"
%><%@ taglib uri="/bbData" prefix="bbData"%>
<bbData:context>
<%   BbSessionManagerService sessionService = BbServiceManager.getSessionManagerService();   
     BbSession bbSession = sessionService.getSession( request );
     AccessManagerService accessManager = (AccessManagerService) BbServiceManager.lookupService( AccessManagerService.class );
%>
<bbUI:docTemplate>
<bbUI:docTemplateHead title='Photo Search'></bbUI:docTemplateHead>
<bbUI:docTemplateBody>
<script language="javascript">
<!-- open will open a new popup -->
function Open(page)
{	var myRef=window.open(page, "Photo_Window", "menubar = no, scrollbars = yes, resizable = 1, width = 500, height = 400").focus();
	myRef.focus();
}
</script>
<script language="javascript">
function disableFields()
{    if(document.getElementById('stud').checked)
     {    document.getElementById('enroll').disabled=false; }
     else
     {    document.getElementById('enroll').disabled=true;
	  document.getElementById('enroll').checked=false;
     }
     
}
function singleSearch(which)
{    var links="/webapps/nu-studentroster-bb_bb60/module/search.jsp?";
     for (i=0;i<which.length;i++)
     {	  if(which.elements[i].name=="userID")
	  {    links=links+"userID="+which.elements[i].value;	 }
	  else if(which.elements[i].name=="studentID")
	  {    links=links+"studentID="+which.elements[i].value; }
     }
     Open(links);
}
function photoValid(which)
{	var errorString="";
	if(!which.DeVos.checked)
	{	if(!which.MI.checked)
		{	if(!which.UC.checked)
			{	if(!which.FL.checked)
				{	if(!which.TX.checked)
					{	errorString="Please select at least one Campus\n";	}
				}
			}
		}
	}
	if(!which.fac.checked)
	{	if(!which.fre.checked)
		{	if(!which.staff.checked)
			{	if(!which.stu.checked)
				{	errorString=errorString+"Please select at least one Classification\n";	}
			}
		}
	}
	if(errorString.length>0)
	{	alert(errorString);
		return false;
	} else
	{	var myRef=window.open('','Photo_Window', '');
		myRef.focus();
		return true;	}
}
</script>
<strong>Select from one of the three Photo Search forms.</strong>
<p />
<form name='userName' onSubmit='singleSearch(this)' METHOD='POST'>
	Username:<br />
	<input type=text name='userID' size=30><input type=submit value='Submit'><br />
	<font size='-2' color='red'>Must provide the whole username(i.e. smith123 as in the email address smith123@northwood.edu)</font>
</FORM>
<table cellpadding=2 width='100%'>
<tr><td width='46%'><hr /></td><td align='center'> OR </td><td width='46%'><hr /></td></tr>
</table>
<form name='studentId' onSubmit='singleSearch(this)' METHOD='POST'>
	ID number (i.e. 0123456): <br />
	<input type=text name='studentID' size=30 maxlength=7><input type=submit value='Submit'><br />
	<font size='-2' color='red'>Must provide the whole Colleague ID including any leading zeros</font>
</FORM>
<table cellpadding=2 width='100%'>
<tr><td width='46%'><hr /></td><td align='center'> OR </td><td width='46%'><hr /></td></tr>
</table>
<font color='red'>At least one campus and classification must be selected for this form.</font>
<FORM ACTION=<%=PlugInUtil.getUri("nu", "studentroster", "module/search_1.jsp") %> onsubmit='return photoValid(this)' METHOD=POST target="Photo_Window">
     <table cellpadding=5>
	  <tr>
	       <td valign=top>Campus:</td>
	       <td><input type=checkbox name='DeVos' value='yes'>DeVos<br />
		    <input type=checkbox name='MI' value='yes'>Michigan&nbsp;&nbsp;&nbsp;<br />
		    <input type=checkbox name='UC' value='yes'>UC
	       </td>
	       <td valign=top>
		    <input type=checkbox name='FL' value='yes'>Florida<br />
		    <input type=checkbox name='TX' value='yes'>Texas
	       </td>
	  </tr>
	  <tr>
	       <td valign=top>Classification:</td>
	       <td valign=top><input type='checkbox' name='fac' value='yes'>Faculty<br />
		    <input id='fresh' type='checkbox' name='fre' value='yes'>New Trad. Undergrad.<br />
	       </td>
	       <td valign=top>
		    <input type='checkbox' name='staff' value='yes'>Staff<br />
		    <input id='stud' type='checkbox' name='stu' value='yes' onClick="javascript:disableFields();">All Students
	       </td>
	       <td valign=top><input id='enroll' type=checkbox name='enr' value='yes' disabled>Active Enrollment in Course</td>
	  </tr>
     </table>
     <table cellpadding=5>
	  <tr>
	       <td valign='top'>
		    Last Name:<font color='red'>*</font>
	       </td>
	       <td valign='top'>
		    <input type=text name='lastName' size=30 />
	       </td>
	  </tr>
	  <tr>
	       <td valign='top'>
		    First Name:<font color='red'>*</font>
	       </td>
	       <td valign='top'>
		    <input type=text name='firstName' size=30/>
	       </td>
	       <td valign='top'>
		    <input type=hidden name='count' value='30' />
		    <input type=hidden name='current' value='1' />
		    <input type=submit value='Submit' />
	       </td>
	  </tr>
     </table>
     <font color='red' size='-2'>* A wild card of '~' can be used to specify where the character
	  string falls in the name.  'Smi~' specifies 'Smi' occurs at start of
	  string and more characters may follow.  '~mit' specifies 'mit' appears
	  after the first character and may have characters following.  'Smith'
	  will match exactly to last name entered.  Leaving the field blank will
	  return all users matching the Classification and Campus.</font>
</FORM>
</bbUI:docTemplateBody>
</bbUI:docTemplate>
</bbData:context>