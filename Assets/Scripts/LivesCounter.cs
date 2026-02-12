using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class LivesCounter : MonoBehaviour
{
    [SerializeField] private int _maxNumOfLives = 3;

    [SerializeField] private int _currentNumOfLives = 3;

    private List<GameObject> lifeSprites = new List<GameObject>();

    public GameObject lifeSpriteExisting;
    public Transform container;
    public float spacing = 1f;

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
        Vector3 existingPos = new Vector3(-10.65f, -5.26f,0f);
        while (lifeSprites.Count > _currentNumOfLives)
        {
            GameObject removing = lifeSprites[lifeSprites.Count - 1];
            lifeSprites.RemoveAt(lifeSprites.Count - 1);
            Destroy(removing);
        }

        while (lifeSprites.Count < _currentNumOfLives)
        {
            GameObject newLife = Instantiate(lifeSpriteExisting, container);
            newLife.transform.position = existingPos + new Vector3(spacing * lifeSprites.Count, 0,0);
            lifeSprites.Add(newLife);
        }
    }
}
