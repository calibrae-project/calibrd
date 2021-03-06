# How to contribute to Calibrae

All contributions to this repository are most welcome. The issues tracker is for tracking issues, which are not necessarily bugs in code, they may include bugs in game logic, and user experience related issues.

These types of latter issues have been described as 'feature requests' in the past, and were basically blocked from entering the discussion. Under Calibrae, such issues will be immediately added to the monthly Hard Fork proposal list and if they make it to the top, become the next change target for the developer group, assuming they do not meet the criteria listed below.

## Coding Style

Specifically for the C++ code, the tool [astyle](http://astyle.sourceforge.net/) should be used, in conjunction with the configuration in the file [.astylerc](.astylerc) found in the root of this repository to automatically format. It is also recommended to use the code editor Visual Studio Code, however, if you do use it, you need to put the following line into the configuration after installing the C/C++ language support extension:

`"C_Cpp.formatting" : "Disabled",`

The original code is not beautified and this drastically diminishes its readability. It is bad enough code that we are working with as it is to compound inconsistent whitespace style, with bad logic.

## Interface front-ends

These have been integrated under the `interfaces` folder, and are acceptable subjects for issues on the Calibrae issue tracker.

## Duplicate Issues

Please do a keyword search to see if there is already an existing issue before opening a new one. If an issue that already exists is repeatedly re-posted, this will be considered spam and the rules relating to this will be followed.

## Feature Requests Policy

Feature requests are best handled by posting on the Steem, or later, Calibrae forum. There will be a monthly post from the developer group, at the beginning of the month, that will compile pending requests for changes in protocols, and based on genuine user feedback about the proposals, one feature request will be selected and put to the Witness Veto process to decide whether it will be implemented or not, after the code has been changed, tested, and results reported.

## Spamming, Trolling and Abusive behaviour

Any user posting such material will be blocked from contributing to the repository, and in the medium term future of the SporeDB based Golang reimplementation, the in-band code repository will use reputation scores specific to the repository to regulate user behaviour.

------

## Old nonsense kept to remind peple what we are leaving behind:

> # ~~Please Read~~
>
> ~~Please read these instructions before submitting issues to the Steem GitHub repository. The issue tracker is for bugs and specific implementation discussion **only**. It should not be used for other purposes, as described below.~~
>
> ## ~~Bug Reports~~
>
> ~~If there is an existing feature that is not working correctly, or a glitch in the blockchain that is impacting user behaviour - please open an issue to report variance. Include as much relevant information as you can, including screen shots or log output when applicable, and steps to reproduce the issue.~~
>
> ## ~~Enhancement Suggestions~~
>
> ~~Do **not** use the issue tracker to suggest enhancements or improvements to the platform. The best place for these discussions is on Steemit.com. If there is a well vetted idea that has the support of the community that you feel should be considered by the development team, please email it to [sneak@steemit.com](mailto:sneak@steemit.com) for review.~~
>
> ## ~~Implementation Discussion~~
>
> ~~The developers frequently open issues to discuss changes that are being worked on. This is to inform the community of the changes being worked on, and to get input from the community and other developers on the implementation.~~
>
> ~~Issues opened that devolve into lengthy discussion of minor site features will be closed or locked.  The issue tracker is not a general purpose discussion forum.~~
>
> ~~This is not the place to make suggestions for product improvement (please see the Enhancement Suggestions section above for this). If you are not planning to work on the change yourself - do not open an issue for it.~~
>
> ## ~~Steemit.com vs. Steem Blockchain~~
>
> ~~This issue tracker is only intended to track issues for the Steem blockchain. If the issue is with the Steemit.com website, please open an issue in the [Steemit.com Repository](https://github.com/steemit/steemit.com/).~~
>
> ## ~~Pull Requests~~
>
> ~~Anybody in the community is welcome and encouraged to submit pull requests with any desired changes to the platform!~~
>
> ~~Requests to make changes that include working, tested pull requests jump to the top of the queue. There is not a guarantee that all functionality submitted as a PR will be accepted and merged, however.~~
>