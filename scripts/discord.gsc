#include scripts\_utility;

init()
{
	setDvarIfUninitialized("scr_discord_webhook_urls", "");

	level thread OnPlayerJoined();
	level thread OnServerEmpty();
}

OnPlayerJoined()
{
	for (;;)
	{
		level waittill("_lifecycle__joined", player);

		if (player isBot()) continue;

		sendWebhookPlayerConnect(player);
	}
}

OnServerEmpty()
{
	for (;;)
	{
		level waittill("_lifecycle__empty_ignorebots");

		sendWebhookServerEmpty();
	}
}

sendWebhookPlayerConnect(newPlayer)
{
	waittillframeend; // wait for player to be added to level.players

	json = "" +
"{" +
	"\"embeds\": [" +
		"{" +
			"\"title\": \"Player joined\"," +
			"\"color\": 9158559," +
			"\"fields\": [" +
				"{" +
					"\"name\": \"Players\"," +
					"\"value\": \"" + buildPlayerList(newPlayer) + "\"," +
					"\"inline\": true" +
				"}," +
				"{" +
					"\"name\": \"Map\"," +
					"\"value\": \"" + getDvar("mapname") + "\"," +
					"\"inline\": true" +
				"}" +
			"]," +
			"\"footer\": {" +
				"\"text\": \"" + stringRemoveColors(getDvar("sv_hostname")) + "\"" +
			"}," +
			"\"timestamp\": \"%ISODATE%\"" +
		"}" +
	"]" +
"}";

	executeWebhook(json);
}

sendWebhookServerEmpty()
{
	json = "" +
"{" +
	"\"embeds\": [" +
		"{" +
			"\"title\": \"Server empty\"," +
			"\"description\": \"Party's over! " + scripts\_http::emoji("new moon face") + "\"," +
			"\"color\": 16543359," +
			"\"footer\": {" +
				"\"text\": \"" + stringRemoveColors(getDvar("sv_hostname")) + "\"" +
			"}," +
			"\"timestamp\": \"%ISODATE%\"" +
		"}" +
	"]" +
"}";

	executeWebhook(json);
}

// sendWebhookRoundEnd()
// {
// 	json = "" +
// "{" +
// 	"\"embeds\": [" +
// 		"{" +
// 			"\"title\": \"Round ended\"," +
// 			"\"description\": \"Party's over! %F0%9F%8C%9A\"," +
// 			"\"color\": 7640298," +
// 			"\"footer\": {" +
// 				"\"text\": \"" + stringRemoveColors(getDvar("sv_hostname")) + "\"" +
// 			"}," +
// 			"\"timestamp\": \"%ISODATE%\"" +
// 		"}" +
// 	"]" +
// "}";

// 	executeWebhook(json);
// }

executeWebhook(json)
{
	urls = strTok(getDvar("scr_discord_webhook_urls"), " ");
	if (urls.size == 0) return;

	headers = [];
	headers["Content-Type"] = "application/json";

	foreach (url in urls)
		request = scripts\_http::httpPost(url, headers, json);
}

buildPlayerList(newPlayer)
{
	str = "";
	foreach (player in level.players)
	{
		newPrefix = "";
		if (isDefined(newPlayer) && player == newPlayer)
			newPrefix = scripts\_http::emoji("new button") + " ";
		str += newPrefix + player.name + "\\n";
	}
	return stringRemoveColors(str);
}
