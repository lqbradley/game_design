using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UIElements;
using UnityEngine.SceneManagement;
using System.Collections.Generic;


public class PlayerController : MonoBehaviour
{   
    public float thrustForce = 0.8f;
    public float maxSpeed = 5f;
    public GameObject boosterFlame;
    public GameObject livesCounter;
    public GameObject explosionEffect;
    public GameObject bounceEffect;
    public GameObject endGameScreen;
    public List<GameObject> borders;
    public float scoreMultiplier = 10f;
    private float score = 0f;
    private float elapsedTime = 0f;
    private Button restartButton;
    private Label scoreText;
    public UIDocument uiDocument;
    Rigidbody2D rb;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        rb = GetComponent<Rigidbody2D>();
        OnEnable();
        scoreText = uiDocument.rootVisualElement.Q<Label>("ScoreLabel");
        restartButton = uiDocument.rootVisualElement.Q<Button>("RestartButton");
        restartButton.style.display = DisplayStyle.None; // remove from display
        restartButton.clicked += ReloadScene;

    }

    // Update is called once per frame
    void Update()
    {
        UpdateScore();
        if (Mouse.current.leftButton.wasPressedThisFrame)
        {
            boosterFlame.SetActive(true);
        }
        else if (Mouse.current.leftButton.wasReleasedThisFrame)
        {
            boosterFlame.SetActive(false);
        }
        MovePlayer();

        
    }

    private void OnEnable()
    {
        if (livesCounter != null)
        {
            livesCounter.GetComponent<LivesCounter>().OutOfLives.AddListener(OnOutOfLives);
        }
    }

    private void OnDisable()
    {
        if (livesCounter != null)
        {
            livesCounter.GetComponent<LivesCounter>().OutOfLives.RemoveListener(OnOutOfLives);
        }
    }
    private void OnOutOfLives()
    {
        Instantiate(explosionEffect, transform.position, transform.rotation);
        restartButton.style.display = DisplayStyle.Flex; // show button
        Destroy(gameObject);
        Instantiate(endGameScreen, Vector3.zero, Quaternion.identity);
        for (int i = 0; i < borders.Count; i++)
        {
            Destroy(borders[i]);
            // or
            // borders[i].SetActive(false);
        }
    
    }

    void ReloadScene()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }

    void MovePlayer()
    {
        if (Mouse.current.leftButton.isPressed)
        {
            Vector3 mousePosition = Camera.main.ScreenToWorldPoint(Mouse.current.position.value);
            Vector2 direction = (mousePosition - transform.position).normalized;
            transform.up = direction;
            rb.AddForce(direction * thrustForce);

            if (rb.linearVelocity.magnitude > maxSpeed)
            {
                rb.linearVelocity = rb.linearVelocity.normalized * maxSpeed;
            }
          
        }
    }

    void UpdateScore()
    {
        elapsedTime += Time.deltaTime;
        score = Mathf.FloorToInt(elapsedTime * scoreMultiplier);
        scoreText.text = "Score: " + score;
    }
    void OnCollisionEnter2D(Collision2D collision)
    {   
        float playerSpeed = rb.linearVelocity.magnitude;
        float objectSpeed = collision.gameObject.GetComponent<Rigidbody2D>() ? collision.gameObject.GetComponent<Rigidbody2D>().linearVelocity.magnitude : 0f;

        float selectedSpeed = Mathf.Max(playerSpeed, objectSpeed);
        // add explosion effect
        Vector2 contactPoint = collision.GetContact(0).point;
        var bounce = Instantiate(bounceEffect, contactPoint, Quaternion.identity);
        bounce.transform.localScale = Vector3.one * selectedSpeed/maxSpeed; // scale effect based on speed
        

        Destroy(bounce, 1f);


        //Destroy(gameObject);
        if (collision.gameObject.CompareTag("Obstacle"))
        {
            LivesCounter livesCounterComponent = livesCounter.GetComponent<LivesCounter>();
            livesCounterComponent.RemoveLife(1);
            livesCounterComponent.UpdateDisplay();
        }
      
    }
}
