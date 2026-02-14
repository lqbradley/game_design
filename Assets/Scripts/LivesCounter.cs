using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class LivesCounter : MonoBehaviour
{
    public int _maxNumOfLives = 5;

    [SerializeField] private int _currentNumOfLives = 5;

    private List<GameObject> lifeSprites = new List<GameObject>();

    public GameObject lifeSpriteExisting;
    public Transform container;
    public float spacing = 1.5f;

    public UnityEvent OutOfLives;
    public int NumOfLives
    {
        get { return _currentNumOfLives; }
        private set
        {
            _currentNumOfLives = Mathf.Clamp(value, 0, _maxNumOfLives);
            if (value <= 0)
            {
                OutOfLives?.Invoke();
            }
        
        }
    }
    public void AddLife(int num)
    {
        NumOfLives += num;
    }
    public void RemoveLife(int num)
    {
        NumOfLives -= num;
    }
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        UpdateDisplay();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void UpdateDisplay()
    {
        Vector3 existingPos = new Vector3(-22.34f, -11.25f,0f);
        
        while (lifeSprites.Count > _currentNumOfLives)
        {
            GameObject removing = lifeSprites[lifeSprites.Count - 1];
            lifeSprites.RemoveAt(lifeSprites.Count - 1);
            // Change the color 
            SpriteRenderer spriteRenderer = removing.GetComponent<SpriteRenderer>();
            spriteRenderer.color = new Color(86f/255f, 48f/255f, 48f/255f);
            //Destroy(removing);
        }

        while (lifeSprites.Count < _currentNumOfLives)
        {
            GameObject newLife = Instantiate(lifeSpriteExisting, container);
            SpriteRenderer sr = newLife.GetComponent<SpriteRenderer>();
            sr.sortingLayerName = "Objects";
            newLife.transform.position = existingPos + new Vector3(spacing * lifeSprites.Count, 0,0);
            lifeSprites.Add(newLife);
        }
    }
}