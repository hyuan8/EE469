# EE469

I copied this from another repo :P

WHAT TO DO WHEN YOU WANT TO WORK ON THE LAB

STEP 1: PREPARATION

sync your main branch:
git checkout main
git pull origin main
create a branch
git checkout -b branch-name
IMPORTANT: YOU NEED THE -b OR ELSE FILES WILL DISAPPEAR. IF THIS DOES HAPPEN, YOU CAN RUN git reset --hard main WHILE IN THE OTHER BRANCH, WHICH WILL MAKE THAT BRANCH IDENTICAL TO MAIN
STEP 2: CODING AND COMMITTING

write your code
stage changes (i always use "git add ." which adds all changed files because im lazy)
git add filename
git add .
commit changes (try to make the message good? it's not that deep for small projects like this, but at least say what you changed)
git commit -m "commit-message"
STEP 3: PUSHING AND REVIEWING

push the branch to github
git push -u origin branch-name
open a pull request
click "Compare & pull request"
leave a note on what you did
click "Create pull request"
STEP 4: INTEGRATION

optional: have partner review the changes (definitely do this for big changes)
in the pull request, go to files changed
if no issues, click "Merge pull request" and then "Confirm merge"
STEP 5: CLEANUP

press delete branch or go to branches and delete the not main branch
pull changes and delete the branch locally
git checkout main
git pull origin main
git branch -d branch-name
SOME NOTES

ANOTHER IMPORTANT THING: so if it doesn't let you push changes because it needs to pull first, to prevent overwriting issues and stuff, you can run git stash first (in your branch). then do git pull origin main, and then git stash pop. Hopefully no errors happen there.
All these terminal commands can (and probably should) be done in the root repository folder.
Any errors can just be copy pasted into gemini or chat. Probably specify that you are not the repository owner but added as a collaborator.
The first time you push to a new branch, use git push -u origin branch-name. The next times, you can just use git push or git pull (the -u is what allows you to do this, if you want you can just do git push origin branch-name every time)
You're supposed to name the branch after what you are working on, but I'm pretty lazy and the projects aren't large so I just do something like "working" or "testing". You could even do "hailey-is-bad" if you wanted to.
Making multiple commits in one session (if you are doing multiple big changes/parts and want to save the previous part before messing around, essentially saving your progress/allowing you to undo all recent changes easily)
Each time, just do git commit -m "message", which is local
Don't do step 3 and onwards
Ask gemini or chat how to go back to most recent git commit because I always forget
This is safe as long as you are on a working branch and not the main branch, so if you accidentally delete everything it's fine (please don't test this, even though it's theoretically safe + I have my local copy as well)
