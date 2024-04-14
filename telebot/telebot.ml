open Telegram

module MyBot = TelegramApi.Mk (struct
  include BotDefaults

  let token = ""

  open TelegramApi

  let global_tabs = Hashtbl.create 10
    (* In_channel.with_open_bin "tabs.store" (fun ic -> *)
    (*     let t : Tab.t = Marshal.from_channel ic in *)
    (*     t *)
    (*   ) *)

  (* Global Commands *)
  let start_cmd: Command.command =
    let run (msg : Message.message) =
      Actions.send_message ~chat_id:msg.chat.id
        "Hi! TabsBot here to keep a running tab of who paid for what!"
    in
    {
      name = "start";
      description = "Set where the tab is record";
      enabled = true;
      run;
    }

  let help_cmd: Command.command =
    let run (msg : Message.message) =
      Actions.send_message ~chat_id:msg.chat.id
        "This is the help command"
    in
    {
      name = "help";
      description = "See available commands";
      enabled = true;
      run;
    }

  (* let settings_cmd : Command.command = failwith "Not implemented" *)

  (* Add an entry to the tab *)
  (* let add_cmd : Command.command = *)
  (*   let run (msg : Message.message) = *)
  (*     match Hashtbl.find_opt global_tab msg.chat.id with *)
  (*     | None -> *)
  (*       let tab = Tab.make () in  *)
  (*       Hashtbl.add msg.chat.id tab; *)
  (*       (\* Tab.make_entry *\) *)
  (*       Tab.add tab *)

  (*     | Some tab -> *)
  (*     Actions. *)
  (*   failwith "Not implemented" *)


  (* Bot Commands *)
  (* let tab_cmd : Command.command = *)
  (*   let run (msg : Message.message) = *)
  (*     Actions.send_message ~chat_id:msg.chat.id *)
  (*       "Hi! TabsBot here to keep a running tab of who paid for what, \ *)
  (*        I'll need a space to write it down, so let me know if you prefer it \ *)
  (*        in the chat description or as a pinned message. After that, no \ *)
  (*        one touch it please!" *)
  (*   in *)
  (*   { *)
  (*     name = "new_tab"; *)
  (*     description = "Set up a new tab for the group"; *)
  (*     enabled = true; *)
  (*     run; *)
  (*   } *)


  (* Delete an entry to the tab *)
  (*   let del_cmd : Command.command = failwith "Not implemented" *)

  let commands = start_cmd :: help_cmd :: BotDefaults.commands
end)

let () = MyBot.run ~log:true ()
