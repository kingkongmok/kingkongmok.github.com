---
layout: post
title: "send mail with perl cgi"
category: perl
tags: [cgi mail perl]
---

##写邮件

**当然的，perl是调用sendmail来进行发邮件。仔细看下24～27行，原来mail的是明文指定了To,Subject这样的，非常有意思。其实通过cgi也可以发邮件了，只是需要修改下from address，否则发出去的都是www-data了。**

{% highlight perl  linenos %}
use strict;
use warnings;
 
use CGI qw(:standard);          # Include standard HTML and CGI functions 
use CGI::Carp qw(fatalsToBrowser);  # Send error messages to browser 
 
 
my $sendmail = '/usr/lib/sendmail';    # Set the path for sendmail (don't use mail!!!) 
 
 
# 
# Start by printing the content-type, the title of the web page and a heading. 
#        
 
 
print header, start_html("Email Form"), h1("Email Form"); 
 
if (param()) {                  # If true,the form has already been filled out. 
 
    my $address = param("address");        # Extract the values passed from the form.
    my $subject = param("subject");           
    my $message = param("message");           
 
    open (MAIL, "| $sendmail -t") or die "Can't open pipe to $sendmail:$!\n"; 
    print MAIL "To: $address\n"; 
    print MAIL "Subject: $subject\n\n";         # Insert blank line between mail headers and message. 
    print MAIL "$message\n"; 
    close(MAIL) or die "Can't close pipe to $sendmail:$!\n"; 
 
    print p("Email has been sent to $address"); # Print confirmation. 
 
} 
else {                      # Else, first time through so present form. 
 
        print start_form();                     
        print p("Enter Email address? ", textfield("address"));
        print p("Enter Subject? ", textfield("subject"));
        print p("Enter Message? ", textarea("message"));
        print p(submit("Submit form"), reset("Clear form"));
        print end_form();
}
print end_html;
{% endhighlight %}


{% highlight perl lineons %}
kk@debian:~$ curl localhost/sendmail.pl
<!DOCTYPE html
    PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<head>
<title>Email Form</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
</head>
<body>
<h1>Email Form</h1><form method="post" action="/sendmail.pl" enctype="multipart/form-data">
<p>Enter Email address?  <input type="text" name="address"  /></p><p>Enter Subject?  <input type="text" name="subject"  /></p><p>Enter Message?  <textarea name="message" ></textarea></p><p><input type="submit" name="Submit form" value="Submit form" /> <input type="reset"  name="Clear form" value="Clear form" /></p></form>
</body>
</html>kk@debian:~$ curl localhost/sendmail.pl?address=kk@fileserver.kk.igb&subjtp
kk@debian:~$ curl "localhost/sendmail.pl?address=kk@fileserver.kk.igb&subject=testperl&message=testmailhere"
<!DOCTYPE html
    PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<head>
<title>Email Form</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
</head>
<body>
<h1>Email Form</h1><p>Email has been sent to kk@fileserver.kk.igb</p>
</body>
</html>
{% endhighlight %}


