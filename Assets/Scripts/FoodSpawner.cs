using UnityEngine;

public class FoodSpawner : MonoBehaviour
{   
    public GameObject foodPrefab;
    public GameObject healingPrefab;
    private GameObject foodObject;
    private GameObject healingObject;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        // instantiating the things
        foodObject = GameObject.Find("FoodObject");
        healingObject = GameObject.Find("Healing");
        SpawnFood();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void SpawnFood()
    {
        foodObject.GetComponent<Food>().RandomizePosition();
        foodObject.tag = "Food";
        foodObject.SetActive(true);
        healingObject.SetActive(false);
    }

    public void SpawnHealing()
    {
        healingObject.GetComponent<Food>().RandomizePosition();
        healingObject.tag = "Healing";
        healingObject.SetActive(true);
        foodObject.SetActive(false);
    }


}
