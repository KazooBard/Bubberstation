# Code Citations

## License: AGPL_3_0
https://github.com/fulpstation/fulpstation/tree/89c060aae240bd8c5605f54a3fa3ffb1ebd5073f/fulp_modules/features/antagonists/bloodsuckers/code/bloodsucker/bloodsucker_crypt.dm

```
obj/structure/bloodsucker/bloodthrone/buckle_mob(mob/living/user, force = FALSE, check_loc = TRUE)
	if(!anchored)
		to_chat(user, span_announce("[src] is not bolted to the ground!"))
		return
	. = ..(
```


## License: AGPL_3_0
https://github.com/fulpstation/fulpstation/tree/89c060aae240bd8c5605f54a3fa3ffb1ebd5073f/fulp_modules/features/bloodsuckers/code/bloodsucker/bloodsucker_crypt.dm

```
= FALSE, check_loc = TRUE)
	if(!anchored)
		to_chat(user, span_announce("[src] is not bolted to the ground!"))
		return
	. = ..()
	user.visible_message(
		span_notice("[user] sits down on [src]
```

