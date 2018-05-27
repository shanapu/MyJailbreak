# Code Contribution Guidelines
***
First, thank you for contribute to the MyJailbreak project!
***
This should be a small guide to avoid unnecessary problems when contributing code to MyJB.
We're aware that the current code of MyJB doesn't fully follow this rules.
We'll update the code to fit these guidelines in future.
Maybe these guidelines could change in future.
***
> “Always code as if the guy who ends up maintaining your code will be a violent psychopath who knows where you live.”  
> - John F. Woods
***
> “Any fool can write code that a computer can understand. Good programmers write code that humans can understand.”  
> - Martin Fowler
***
### Announce your work as issue
**to avoid double work**
***
### Send pull requests always to 'dev' branch
***
### All sourcepawn (.sp /.inc) files need a GPL header
**don't forget to credit yourself**
***
### Comment your code
**doing some magic? explain it!  
you don't need to comment "standard" code**
***
### Give credits
**(re)use code from an other author? give him credits as a comment above the snippet**
***
### Use tabs for indentation
**activate 'show spaces & tabs' in your editor**

***
### Use brackets in their own lines ~ Allman / BSD

examples:

:white_check_mark: good:
```
	if (check)
	{
		function();
	}
	else
	{
		function2();
	}

	if (check)
	{
		function();

		return;
	}
```

:x: bad:
```
	if (check) {
		function(); }

	if (check) { function(); }

	if (check) {
		function();
		}

	if (check)
	{ function(); }

	if (check)
		{
		function();
		}

	if (check)
		{
			function();
		}

	if (check)
		function();

	if (check) function();

	if (check) function();
		return;
```
... and variants

:alien: exception only on a return immediately after check:
```
	if (check)
		return Plugin_Continue;

	if (check)
		continue; //break, ...
```
***
### Try to avoid bracket nesting with returns

examples:

:white_check_mark: good:
```
	function()
	{
		if (!check1)
			return;

		if (!check2)
			return;

		if (!check3)
			return;

		if (!check4)
			return;

		function2();
	}
```
:x: bad:
```
	function()
	{
		if (check1)
		{
			if (check2)
			{
				if (check3)
				{
					if (check4)
					{
						function2();
					}
				}
			}
		}
	}
```
***
### Try to 'outsource' repeating/identical code parts to own function 

examples:

:white_check_mark: good:
```
	function1()
	{
		function3()
	}

	function2()
	{
		function3()
	}

	function3()
	{
		g_iInteger++;
		function4(g_iInteger, g_fFloat, g_bBool);

		function5(g_fFloat);

		function6(g_bBool);
	}
```
:x: bad:
```
	function1()
	{
		g_iInteger++;
		function4(g_iInteger, g_fFloat, g_bBool);

		function5(g_fFloat);

		function6(g_bBool);
	}

	function2()
	{
		g_iInteger++;
		function4(g_iInteger, g_fFloat, g_bBool);

		function5(g_fFloat);

		function6(g_bBool);
	}
```
***
### Space and group with extra lines with no tabs to increase readability  
**activate 'show spaces & tabs' in your editor**  

examples:

:white_check_mark: good:
```
	if (check)
	{
		bool bBool = true;
		int iInteger;
		float fFloat = 0.1;

		int iInteger = function(iInteger);
		function2(iInteger, fFloat, bBool);

		function3(fFloat);  // no tabs in space lines

		function4(bBool);

		return Plugin_Handled;
	}
```
:x: bad:
```
	if (check)
	{
		bool bBool = true;
		int iInteger;
		float fFloat = 0.1;
		int iInteger = function(iInteger);
		function2(iInteger, fFloat, bBool);
		function3(fFloat);
		function4(bBool);
		return Plugin_Handled;
	}
	
	if (check)
	{
		bool bBool = true;
		int iInteger;
		float fFloat = 0.1;
		//here are tabs
		int iInteger = function(iInteger);
		function2(iInteger, fFloat, bBool);
		//here are tabs
		function3(fFloat);
		//here are tabs
		function4(bBool);
		return Plugin_Handled;
	}
```
***
### Use space behind 'if', 'for' 'while' and behind ',' and never after a '(' or before ')' 

examples:

:white_check_mark: good:
```
	Example(integer, float, bool);

	if (check)

	for (int i = 1; i <= MaxClients; i++)
```
:x: bad:
```
	Example(integer,float,bool);
	Example( integer , float , bool );

	if(check)

	for(int i = 1;i <= MaxClients;i++)
```
***
### Use space around operators

examples:

:white_check_mark: good:
```
	if (1 + 2 == 3)

	for (int i = 1; i <= MaxClients; i++)
```
:x: bad:
```
	if (1+2==3)

	for (int i=1; i<=MaxClients; i++)
```
***
### On addition and subtraction use the simplified way  

examples:

:white_check_mark: good:
```
	iInteger++;
	iInteger--;

	iInteger1 += iInteger2;
	iInteger1 -= iInteger2;
```
:x: bad:
```
	iInteger = iInteger + 1;
	iInteger = iInteger - 1;
	iInteger += 1;
	iInteger -= 1;

	iInteger1 = iInteger1 + iInteger2;
	iInteger1 = iInteger1 - iInteger2;
```
***
### Use for menus & panel methodmaps instead functions 
**try to use methodmaps for arrays, tries, datapacks, ...**
examples:

:white_check_mark: good:
```
	Panel menu = new Panel();
	menu.SetTitle("Title");
	menu.DrawItem("Item");
	menu.Send(client, Handler, MENU_TIME);

	Menu menu = CreateMenu(Handler);
	menu.SetTitle(sBuffer);
	menu.AddItem("1", "Item")
	menu.Display(client, MENU_TIME);
```
... and variants  
:x: bad:
```
	Handle panel = CreatePanel();
	SetPanelTitle(panel, "Title");
	DrawPanelItem(panel, "Item");
	SendPanelToClient(panel, client, Handler, MENU_TIME);
	
	Handle menu = CreateMenu(Handler);
	SetMenuTitle(menu, "Title");
	AddMenuItem(menu, "1", "Item");
	DisplayMenu(menu, client, MENU_TIME);
```
... and variants
***
### Only pass userid instead of clientid in timer or RequestFrame  

examples:

:white_check_mark: good:
```
		CreateTimer(0.1, Timer_Example, GetClientUserId(client));
	}

	public Action Timer_Example(Handle tmr, int userid)
	{
		int client = GetClientOfUserId(userid);

		//code
	}
```
:x: bad:
```
		CreateTimer(0.1, Timer_Example, client);
	}

	public Action Timer_Example(Handle tmr, int client)
	{
		//code
	}
```
***
### When possible add chat prints to end of a function - so when a translation is missing the function still works  

examples:

:white_check_mark: good:
```
	function()
	{
		function2();  // will fire when "translation_phrass" is missing

		PrintToChatAll("%t", "translation_phrass");
	}
```
:x: bad:
```
	function()
	{
		PrintToChatAll("%t", "translation_phrass");

		function2();  // will not fire when "translation_phrass" is missing
	}
```
***
## Naming:  

**use English language**

### Variables:
non global - except 'client', 'attacker', 'victim'
```
iBetHRSmall
| | |   |
| | |   └ Name
| | |
| | └ optional - if concerning to a repeating special function like timer or more variables belongs to a single function
| |
| └ optional - if concerning to a repeating special function like timer or more variables belongs to a single function
|
└ bool, char, float, handle, integer
```
global
```
g_iTimerRollStart
| |  |    |   |
| |  |    |   └ Name
| |  |    |
| |  |    └ optional - if concerning to a repeating special function like timer or more variables belongs to a single function
| |  |
| |  └ optional - if concerning to a repeating special function like timer or more variables belongs to a single function
| |
| └ bool, char, float, handle, integer
|
└ global
```
global Convar
```
gc_iTimerRollStart
|  |  |    |   |
|  |  |    |   └ Name
|  |  |    |
|  |  |    └ optional - if concerning to a repeating special function like timer or more variables belongs to a single function
|  |  |
|  |  └ optional - if concerning to a repeating special function like timer or more variables belongs to a single function
|  |
|  └ bool, char, float, handle, integer
|
└ global convar
```
Functions

### Name function after their 'Action' (if given), underline and their usage

examples:

```
Command_Example(int client);
Menu_Example(int client);
Panel_Example(int client);
Handler_Example(Menu menu, MenuAction action, int client, int itemNum);
```
**The parameters of the functions should keep their original description, if not given use lowercase characters without the bool, char, float, handle, integer prefix**
***


Version 1.0 of MyJailbreaks Code Contribution Guidelines