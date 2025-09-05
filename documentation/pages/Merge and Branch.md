# Merge
- ## Note
- When performing a merge make sure too:
	- Close all editors: Godot, LogSeq, Trenchbroom, VsCode, etc.
	- Otherwise may cause issue with creating untracked modifications or changes
- ### Steps to merge
- Properly secure branch to be merged with final add, commit, and push.
  logseq.order-list-type:: number
- Close all editors!  Godot, LogSeq, Trenchbroom, VsCode, etc.
  logseq.order-list-type:: number
- Ensure everything is secured with git status.
  logseq.order-list-type:: number
- git checkout master
  logseq.order-list-type:: number
- git pull
  logseq.order-list-type:: number
	- Make sure master is up to date
	  logseq.order-list-type:: number
- git merge your-feature-branch
  logseq.order-list-type:: number
- git push origin master
  logseq.order-list-type:: number
- ### Useful commands
- git reset --hard
	- Resets entire project folder to last commit
- git clean -n -d
	- `-n` is for a "dry run" (it only lists the files).
	- `-d` tells it to also look for untracked directories.
	- dry run to see list of files that will be deleted
- git clean -fd
	- Permenantly delete these files.
- Useful if have lingering untracked files by accident after doing proper commit routine on branch to merge. Because of editors being open.
- These will help in restting the branch to its proper state and clean any created files that were automatically generated.
- Allowing for branches to be clean and in sync with repo. To allow for a safe merge
- # Branch
- git branch <Branch name>
  logseq.order-list-type:: number
	- Create branch
	  logseq.order-list-type:: number
- git checkout <newly created branch>
  logseq.order-list-type:: number
	- Switch to branch
	  logseq.order-list-type:: number
- git push --set-upstream origin <newly created branch>
  logseq.order-list-type:: number
	- Push branch to remote repo
	  logseq.order-list-type:: number
-