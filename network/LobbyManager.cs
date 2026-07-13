using Godot;

public abstract partial class LobbyManager : Node
{
	public abstract Error CreateGame();
	public abstract Error JoinGame(string address = "");
	public virtual void OpenInviteOverlay() { }
	public abstract void KickPeer(int peerId);
	public abstract void DisconnectServer();
}
