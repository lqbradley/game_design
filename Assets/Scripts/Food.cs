using UnityEngine;

public class Food : MonoBehaviour
{
    public BoxCollider2D gridArea;

    public float minTimeToDecay = 4f;
    public float maxTimeToDecay = 8f;
    private float elapsedTime = 0f;
    private float totalElapsedTime = 0f;
    public float timeToIncreasedDifficulty = 15f;
    
    public float repeatRate = 0.15f;
    private bool animationStarted = false;

    
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {   
       RandomizePosition();
    }

    // Update is called once per frame
    void Update()
    {
        
        Decay();
        // IncreaseDifficulty(); // TODO: Think about a better way to implement this
    }

    void DoAnimation()
    {
        if (animationStarted) return;  // only start once
        animationStarted = true;

        InvokeRepeating(nameof(ChangeStateObject), 0f, repeatRate);  // start toggling    
        Invoke(nameof(StopAnimation), 0.3f);  // stop after a short duration         
    }

    void StopAnimation()
    {
        CancelInvoke(nameof(ChangeStateObject));
    }


    void ChangeStateObject()
    {
        gameObject.SetActive(!gameObject.activeInHierarchy);
    }

    public void RandomizePosition()
    {
        elapsedTime = 0f;
        animationStarted = false;
        SpriteRenderer spriteRenderer = this.GetComponent<SpriteRenderer>();
        spriteRenderer.color = Color.white;
        Bounds bounds = this.gridArea.bounds; 
        float x = Mathf.Round(Random.Range(bounds.min.x, bounds.max.x)); 
        float y = Mathf.Round(Random.Range(bounds.min.y, bounds.max.y)); 
        this.transform.position = new Vector3(Mathf.Round(x), Mathf.Round(y), 1.0f);
    }

    private void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Snake"))
        {
            RandomizePosition();
        }
    }

    private void Decay()
    {   
        elapsedTime += Time.deltaTime;
        Color decay2 = new Color (159f/255f, 84f/255f, 84f/255f);
        Color decay3 = new Color(66f/255f, 15f/255f, 15f/255f);

        float timeToDecay = Random.Range(minTimeToDecay, maxTimeToDecay);
        if (this.tag == "Healing")
        {
            timeToDecay = timeToDecay * 0.75f; // Healing decays faster than food
        }

        
   
        if (elapsedTime >= timeToDecay)
        {
           RandomizePosition();
        } 
        else if (elapsedTime >= 0.55*timeToDecay )
        {   
            SpriteRenderer spriteRenderer = this.GetComponent<SpriteRenderer>();
            spriteRenderer.color = decay2;
            if (this.tag == "Healing")
            {
                this.tag = "InstantDeath";
            } else
            {
                 this.tag = "Poison";
            }
        
        } 
        else if (elapsedTime >= 0.55f * timeToDecay - 0.3f 
                    && elapsedTime < 0.55f * timeToDecay 
                    && !animationStarted)
            {
                DoAnimation();  
            }
        // else if (elapsedTime >= 0.20*timeToDecay)
        // {
        //     SpriteRenderer spriteRenderer = this.GetComponent<SpriteRenderer>();
        //     spriteRenderer.color = decay2;
        // }
    }
    private void IncreaseDifficulty()
    {
        totalElapsedTime += Time.deltaTime;
        float intensity = totalElapsedTime / timeToIncreasedDifficulty * 0.1f; 
        minTimeToDecay -= intensity;
        maxTimeToDecay -= intensity;
    }



  
}
