class PositionedSceneElement
{
    private Picture myPic;
    private PositionedSceneElement next;
    private PositionedSceneElement prev;
    public PositionedSceneElement(Picture heldPic)
    {
      myPic = heldPic;
      next = null;
      prev = null;
    }
    public void setPrev(PositionedSceneElement x)
    {
      prev = x;
    }
    public PositionedSceneElement getPrev()
    {
      return prev;
    }
    public void setNext(PositionedSceneElement x)
    {
      next = x;
    }
    public PositionedSceneElement getNext()
    {
      return next;
    }
    public Picture getPicture()
    {
      return myPic;
    }
}
