#!/bin/bash

githubUser=emberfeather
projectPath=~/Projects
webrootPath=~/Servers/lucee/webapps/ROOT/
projects=(algid cf-compendium one20 mongo4cf postmark4cf)
plugins=(account admin api chart content cron documentation editor error google i18n mongodb parser plugins postmark scm search security survey tagger tracker user user-openid user-local widget wiki)

echo "================================"
echo " One20 Development Setup Script"
echo "================================"
echo "Using the $githubUser Github user for projects"
echo "Project path: $projectPath"
echo "Webroot path: $webrootPath"
echo "Projects: ${projects[*]}"
echo "Plugins: ${plugins[*]}"
echo "================================"
echo ""

# Verify that the server is already setup.
if [ ! -d $webrootPath ]
then
  echo "Missing Lucee server: $webrootPath"
  exit 1
fi

# Create a directory for the plugins in the webroot.
if [ ! -d $webrootPath/p ]
then
	echo "Creating: $webrootPath/p"
	mkdir $webrootPath/p
fi

# Create a directory for the projects
if [ ! -d $projectPath ]
then
	echo "Creating: $projectPath"
	mkdir $projectPath
fi

# Create a directory for the plugins
if [ ! -d $projectPath/plugins ]
then
	echo "Creating: $projectPath/plugins"
	mkdir $projectPath/plugins
fi

# Create a directory for the wikis
if [ ! -d $projectPath/wiki ]
then
	echo "Creating: $projectPath/wiki"
	mkdir $projectPath/wiki
fi

# Create a directory for the plugin wikis
if [ ! -d $projectPath/wiki/plugins ]
then
	echo "Creating: $projectPath/wiki/plugins"
	mkdir $projectPath/wiki/plugins
fi

# Checkout and initialize the projects
for project in ${projects[*]}
do
	if [ ! -d $projectPath/$project ]
	then
		echo "Cloning to: $projectPath/$project"
		git clone --recurse-submodules git@github.com:$githubUser/$project.git $projectPath/$project

		cd $projectPath/$project

		git submodule update --init
	else
		echo "Updating submodules: $projectPath/$project"

		cd $projectPath/$project

		git submodule update --init
	fi
done

# Symbolic link the projects into the webroot
if [ ! -h $webrootPath/a ]
then
	echo "Linking: Projects into webroot"
	ln -s $projectPath/algid $webrootPath/a
	ln -s $projectPath/algid/algid $webrootPath/algid
	ln -s $projectPath/algid/server/lucee/context/templates/debugging/debugging-algid-12.cfm $webrootPath/WEB-INF/lucee/context/templates/debugging/debugging-algid-12.cfm
fi


if [ ! -h $webrootPath/c ]
then
	ln -s $projectPath/cf-compendium $webrootPath/c
	ln -s $projectPath/cf-compendium/cf-compendium $webrootPath/cf-compendium
fi


if [ ! -h $webrootPath/o ]
then
	ln -s $projectPath/one20 $webrootPath/o
	ln -s $projectPath/one20/one20 $webrootPath/one20
fi

if [ ! -h $webrootPath/m ]
then
	ln -s $projectPath/mongo4cf $webrootPath/m
	ln -s $projectPath/mongo4cf/mongo4cf $webrootPath/mongo4cf
fi

if [ ! -h $webrootPath/pm ]
then
	ln -s $projectPath/postmark4cf $webrootPath/pm
	ln -s $projectPath/postmark4cf/postmark4cf $webrootPath/postmark4cf
fi

# Create the application component
if [ ! -e $projectPath/one20/one20/Application.cfc ]
then
        echo "Creating: $projectPath/one20/one20/Application.cfc"
        echo "component extends=\"ApplicationBase\" {
        this.name = 'one20';
        this.sessionTimeout = __determineSessionTimeout([ '/one20/api/', '/one20/cron/' ]);

        include template = \"plugins/error/inc/resource/application/error.cfm\";
}" > $projectPath/one20/one20/Application.cfc
fi

# Create a plugins directory for the one20 application
if [ ! -d $projectPath/one20/one20/plugins ]
then
	echo "Creating: $projectPath/one20/one20/plugins"
	mkdir $projectPath/one20/one20/plugins
fi

# Checkout and initialize the plugins
for plugin in ${plugins[*]}
do
	if [ ! -d $projectPath/plugins/$plugin ]
	then
		echo "Cloning to: $projectPath/plugins/$plugin"
		git clone --recurse-submodules git@github.com:$githubUser/algid-$plugin.git $projectPath/plugins/$plugin

		cd $projectPath/plugins/$plugin

		# Setup tracking on the develop branch
		git branch develop origin/develop

		# Checkout the develop branch
		git checkout develop
	else
    echo "Pulling: $plugin"

    cd $projectPath/plugins/$plugin
    git pull

		echo "Updating submodules: $plugin"

    git submodule update
	fi
done

# Symbolic link the plugins into the webroot.
for plugin in ${plugins[*]}
do
	if [ ! -h $webrootPath/p/$plugin ]
	then
		echo "Linking: $plugin into webroot"
		ln -s $projectPath/plugins/$plugin/$plugin $projectPath/one20/one20/plugins/$plugin
		ln -s $projectPath/plugins/$plugin $webrootPath/p/$plugin
	fi
done

# Symbolic link the plugins into the application.
for plugin in ${plugins[*]}
do
	if [ ! -h $projectPath/one20/one20/plugins/$plugin ]
	then
		echo "Linking: $plugin into application"
		ln -s $projectPath/plugins/$plugin/$plugin $projectPath/one20/one20/plugins/$plugin
	fi
done

# Checkout and initialize the project wikis
for project in ${projects[*]}
do
	if [ ! -d $projectPath/wiki/$project ]
	then
		echo "Cloning to: $projectPath/wiki/$project"
		git clone --recurse-submodules git@github.com:$githubUser/$project.wiki.git $projectPath/wiki/$project

		cd $projectPath/wiki/$project/$project
	fi
done

# Checkout and initialize the plugin wikis
for plugin in ${plugins[*]}
do
	if [ ! -d $projectPath/wiki/plugins/$plugin ]
	then
		echo "Cloning to: $projectPath/wiki/plugins/$plugin"
		git clone --recurse-submodules git@github.com:$githubUser/algid-$plugin.wiki.git $projectPath/wiki/plugins/$plugin

		cd $projectPath/wiki/plugins/$plugin
	fi
done
